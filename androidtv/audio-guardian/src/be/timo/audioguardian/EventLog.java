package be.timo.audioguardian;

import android.content.Context;
import android.util.Log;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

final class EventLog {
    private EventLog() {}

    static synchronized void write(Context context, String message) {
        Log.i("AudioGuardian", message);
        File file = new File(context.getFilesDir(), "events.log");
        try {
            if (file.length() >= 65536) {
                File previous = new File(context.getFilesDir(), "events.previous.log");
                if (previous.exists() && !previous.delete()) {
                    throw new IOException("Unable to remove previous event log");
                }
                if (!file.renameTo(previous)) {
                    throw new IOException("Unable to rotate event log");
                }
            }
            String timestamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.ROOT)
                    .format(new Date());
            try (FileOutputStream output = new FileOutputStream(file, true)) {
                output.write((timestamp + " " + message + "\n").getBytes(StandardCharsets.UTF_8));
            }
        } catch (IOException error) {
            Log.e("AudioGuardian", "Unable to save diagnostic log", error);
            context.getSharedPreferences("guardian", Context.MODE_PRIVATE).edit()
                    .putString("status", "ERROR: unable to save diagnostic log").apply();
        }
    }

    static synchronized String read(Context context) {
        File file = new File(context.getFilesDir(), "events.log");
        if (!file.exists()) {
            return "No service events yet.";
        }
        try {
            String text = new String(Files.readAllBytes(file.toPath()), StandardCharsets.UTF_8);
            return text.substring(Math.max(0, text.length() - 6000));
        } catch (IOException error) {
            Log.e("AudioGuardian", "Unable to read diagnostic log", error);
            return "ERROR: unable to read diagnostic log";
        }
    }
}
