package be.timo.audioguardian;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public final class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if ((Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())
                || Intent.ACTION_MY_PACKAGE_REPLACED.equals(intent.getAction()))
                && context.getSharedPreferences("guardian", Context.MODE_PRIVATE)
                        .getBoolean("enabled", false)) {
            EventLog.write(context, "Starting after " + intent.getAction());
            context.startForegroundService(new Intent(context, GuardianService.class));
        }
    }
}
