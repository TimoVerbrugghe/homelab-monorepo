package be.timo.audioguardian;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public final class MainActivity extends Activity {
    private final Handler handler = new Handler(Looper.getMainLooper());
    private TextView status;
    private TextView events;
    private SharedPreferences preferences;
    private final Runnable refresh = new Runnable() {
        @Override
        public void run() {
            status.setText("Paired: " + new SonyClient(MainActivity.this).isPaired()
                    + " | Enabled: " + preferences.getBoolean("enabled", false)
                    + "\n" + preferences.getString("status", "Not started")
                    + "\nPause before deliberately using TV speakers or disconnecting the soundbar.");
            events.setText(EventLog.read(MainActivity.this));
            handler.postDelayed(this, 2000);
        }
    };

    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        preferences = getSharedPreferences("guardian", MODE_PRIVATE);
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(48, 24, 48, 24);
        TextView title = new TextView(this);
        title.setText("Audio Guardian");
        title.setTextSize(26);
        layout.addView(title);
        status = new TextView(this);
        status.setTextSize(16);
        layout.addView(status);
        button(layout, "Enable / resume recovery", () -> {
            if (!new SonyClient(this).isPaired()) {
                preferences.edit().putString("status",
                        "Pair once using the ADB setup helper; see the project README.").apply();
                return;
            }
            if (Build.VERSION.SDK_INT >= 33
                    && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)
                            != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(new String[] {Manifest.permission.POST_NOTIFICATIONS}, 1);
            }
            preferences.edit().putBoolean("enabled", true).putLong("paused_until", 0).apply();
            startForegroundService(new Intent(this, GuardianService.class));
        });
        button(layout, "Pause recovery for 30 minutes", () -> {
            preferences.edit().putLong("paused_until",
                    System.currentTimeMillis() + 30 * 60 * 1000).apply();
            EventLog.write(this, "User paused recovery for 30 minutes");
        });
        button(layout, "Disable recovery (including after reboot)", () -> {
            preferences.edit().putBoolean("enabled", false)
                    .putString("status", "Disabled by user").apply();
            stopService(new Intent(this, GuardianService.class));
        });
        events = new TextView(this);
        events.setTextSize(13);
        ScrollView scroll = new ScrollView(this);
        scroll.addView(events);
        layout.addView(scroll, new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 0, 1));
        setContentView(layout);
    }

    private void button(LinearLayout parent, String text, Runnable action) {
        Button button = new Button(this);
        button.setText(text);
        button.setOnClickListener(view -> action.run());
        parent.addView(button);
    }

    @Override
    public void onResume() {
        super.onResume();
        handler.post(refresh);
    }

    @Override
    public void onPause() {
        handler.removeCallbacks(refresh);
        super.onPause();
    }
}
