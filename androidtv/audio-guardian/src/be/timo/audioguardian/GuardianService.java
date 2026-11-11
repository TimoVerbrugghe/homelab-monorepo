package be.timo.audioguardian;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.media.AudioDeviceInfo;
import android.media.AudioDeviceCallback;
import android.media.AudioManager;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.PowerManager;
import android.os.SystemClock;
import java.io.FileDescriptor;
import java.io.IOException;
import java.io.PrintWriter;

public final class GuardianService extends Service {
    private static final String CHANNEL = "audio-guardian";
    private static final int NOTIFICATION_ID = 1;
    private static final long POLL_MS = 1000;
    private SharedPreferences preferences;
    private SonyClient sony;
    private PowerManager power;
    private AudioManager audio;
    private HandlerThread thread;
    private Handler worker;
    private RecoveryPolicy policy;
    private volatile boolean destroyed;
    private volatile long checks;
    private volatile long recoveries;
    private volatile String lastOutput = "unknown";
    private volatile boolean arcAvailable;
    private String previousStatus = "";

    private final Runnable tick = this::check;
    private final AudioDeviceCallback deviceCallback = new AudioDeviceCallback() {
        @Override
        public void onAudioDevicesAdded(AudioDeviceInfo[] devices) {
            recheck();
        }

        @Override
        public void onAudioDevicesRemoved(AudioDeviceInfo[] devices) {
            recheck();
        }
    };

    private void recheck() {
        if (destroyed) {
            return;
        }
        worker.removeCallbacks(tick);
        worker.post(tick);
    }

    private final BroadcastReceiver screenReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            worker.post(() -> {
                worker.removeCallbacks(tick);
                policy.reset();
                if (power.isInteractive()) {
                    status("Awake: resuming audio recovery");
                    worker.post(tick);
                } else {
                    status("Standby: monitoring suspended; no network requests");
                }
            });
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        preferences = getSharedPreferences("guardian", MODE_PRIVATE);
        sony = new SonyClient(this);
        power = getSystemService(PowerManager.class);
        audio = getSystemService(AudioManager.class);
        NotificationManager notifications = getSystemService(NotificationManager.class);
        notifications.createNotificationChannel(new NotificationChannel(
                CHANNEL, "Audio recovery", NotificationManager.IMPORTANCE_LOW));
        startForeground(NOTIFICATION_ID, notification("Starting audio monitor"));
        thread = new HandlerThread("audio-guardian");
        thread.start();
        worker = new Handler(thread.getLooper());
        policy = new RecoveryPolicy();
        audio.registerAudioDeviceCallback(deviceCallback, worker);
        IntentFilter filter = new IntentFilter(Intent.ACTION_SCREEN_ON);
        filter.addAction(Intent.ACTION_SCREEN_OFF);
        if (Build.VERSION.SDK_INT >= 33) {
            registerReceiver(screenReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
        } else {
            registerReceiver(screenReceiver, filter);
        }
        EventLog.write(this, "Service created; wake locks=none; polling=1s; speaker settling=1s");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && "disable".equals(intent.getAction())) {
            preferences.edit().putBoolean("enabled", false).apply();
        }
        if (!preferences.getBoolean("enabled", false)) {
            stopSelf();
            return START_NOT_STICKY;
        }
        worker.post(() -> {
            worker.removeCallbacks(tick);
            if (!power.isInteractive()) {
                status("Standby: monitoring suspended; no network requests");
            } else {
                worker.post(tick);
            }
        });
        return START_STICKY;
    }

    private void check() {
        if (destroyed) {
            return;
        }
        if (!preferences.getBoolean("enabled", false)) {
            stopSelf();
            return;
        }
        if (!power.isInteractive()) {
            policy.reset();
            status("Standby: monitoring suspended; no network requests");
            return;
        }
        long pausedUntil = preferences.getLong("paused_until", 0);
        if (System.currentTimeMillis() < pausedUntil) {
            policy.reset();
            status("Paused: automatic recovery is temporarily disabled");
            schedule();
            return;
        }
        boolean writeAttempted = false;
        try {
            checks++;
            lastOutput = sony.output();
            arcAvailable = false;
            boolean otherDevice = false;
            for (AudioDeviceInfo device : audio.getDevices(AudioManager.GET_DEVICES_OUTPUTS)) {
                int type = device.getType();
                if (type == AudioDeviceInfo.TYPE_HDMI_ARC
                        || type == AudioDeviceInfo.TYPE_HDMI_EARC) {
                    arcAvailable = true;
                }
                if (type == AudioDeviceInfo.TYPE_WIRED_HEADPHONES
                        || type == AudioDeviceInfo.TYPE_WIRED_HEADSET
                        || type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP
                        || type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO
                        || type == AudioDeviceInfo.TYPE_USB_HEADSET
                        || type == AudioDeviceInfo.TYPE_USB_DEVICE
                        || type == AudioDeviceInfo.TYPE_BLE_HEADSET) {
                    otherDevice = true;
                }
            }
            long now = SystemClock.elapsedRealtime();
            RecoveryPolicy.Decision decision = policy.observe(
                    now, lastOutput, arcAvailable, otherDevice);
            switch (decision) {
                case RECOVER:
                    if (destroyed || !power.isInteractive()
                            || !preferences.getBoolean("enabled", false)
                            || System.currentTimeMillis()
                                    < preferences.getLong("paused_until", 0)) {
                        policy.reset();
                        break;
                    }
                    policy.attempted(now);
                    writeAttempted = true;
                    recoveries++;
                    status("Recovery requested: selecting audio system");
                    sony.selectAudioSystem();
                    policy.accepted(SystemClock.elapsedRealtime());
                    status("Verifying audio-system selection and ARC availability");
                    break;
                case RECOVERED:
                    status("Recovery verified: audio system selected and ARC available");
                    break;
                case HEALTHY:
                    status("Healthy: audio system selected and ARC available");
                    break;
                case OTHER_OUTPUT:
                    status("Other audio output detected: leaving routing unchanged");
                    break;
                case VERIFYING:
                    status("Verifying audio-system selection and ARC availability");
                    break;
                default:
                    status("Waiting: retry interval or HDMI settling window");
                    break;
            }
        } catch (SonyClient.AuthorizationException error) {
            if (writeAttempted) {
                policy.failed(SystemClock.elapsedRealtime());
            }
            status("ERROR: Sony pairing required; disable and pair again");
        } catch (IOException error) {
            if (writeAttempted) {
                policy.failed(SystemClock.elapsedRealtime());
            }
            status("ERROR: " + error.getMessage());
        }
        schedule();
    }

    private void schedule() {
        if (!destroyed) {
            worker.postDelayed(tick, POLL_MS);
        }
    }

    private void status(String message) {
        if (destroyed) {
            return;
        }
        if (!message.equals(previousStatus)) {
            previousStatus = message;
            preferences.edit().putString("status", message).apply();
            EventLog.write(this, message);
            getSystemService(NotificationManager.class)
                    .notify(NOTIFICATION_ID, notification(message));
        }
    }

    private Notification notification(String message) {
        PendingIntent open = PendingIntent.getActivity(this, 0,
                new Intent(this, MainActivity.class),
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        PendingIntent disable = PendingIntent.getService(this, 1,
                new Intent(this, GuardianService.class).setAction("disable"),
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        return new Notification.Builder(this, CHANNEL)
                .setSmallIcon(android.R.drawable.ic_lock_silent_mode_off)
                .setContentTitle("Audio Guardian")
                .setContentText(message)
                .setContentIntent(open)
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .addAction(new Notification.Action.Builder(
                        null, "Disable", disable).build())
                .build();
    }

    @Override
    public void onDestroy() {
        destroyed = true;
        audio.unregisterAudioDeviceCallback(deviceCallback);
        unregisterReceiver(screenReceiver);
        worker.removeCallbacksAndMessages(null);
        thread.quitSafely();
        stopForeground(STOP_FOREGROUND_REMOVE);
        EventLog.write(this, "Service destroyed");
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    protected void dump(FileDescriptor fd, PrintWriter writer, String[] arguments) {
        writer.println("enabled=" + preferences.getBoolean("enabled", false));
        writer.println("interactive=" + power.isInteractive());
        writer.println("pausedUntil=" + preferences.getLong("paused_until", 0));
        writer.println("checks=" + checks + " recoveries=" + recoveries);
        writer.println("lastOutput=" + lastOutput + " arcAvailable=" + arcAvailable);
        writer.println("status=" + preferences.getString("status", "unknown"));
        writer.println(EventLog.read(this));
    }
}
