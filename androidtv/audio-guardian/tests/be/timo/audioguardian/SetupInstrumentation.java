package be.timo.audioguardian;

import android.app.Activity;
import android.app.Instrumentation;
import android.os.Bundle;
import java.io.IOException;

public final class SetupInstrumentation extends Instrumentation {
    private String pin;

    @Override
    public void onCreate(Bundle arguments) {
        super.onCreate(arguments);
        pin = arguments == null ? null : arguments.getString("pin");
        start();
    }

    @Override
    public void onStart() {
        new Thread(() -> {
            Bundle result = new Bundle();
            int code = Activity.RESULT_CANCELED;
            try {
                new SonyClient(getTargetContext()).pair(pin == null ? "0000" : pin);
                result.putString("stream", "\nPairing succeeded. Remove the setup APK, "
                        + "then open Audio Guardian and enable recovery.\n");
                code = Activity.RESULT_OK;
            } catch (SonyClient.AuthorizationException error) {
                result.putString("stream", pin == null
                        ? "\nPairing requested. Enter the PIN shown on the TV using -e pin.\n"
                        : "\nPairing rejected. Request a fresh PIN and try again.\n");
            } catch (IOException error) {
                result.putString("stream", "\nERROR: " + error.getMessage() + "\n");
            }
            finish(code, result);
        }, "audio-guardian-pairing").start();
    }
}
