package be.timo.audioguardian;

import java.io.IOException;

final class AuthorizationRecovery {
    static final int READY = 0;
    static final int BLOCKED = 1;
    static final int VERIFY_WRITE = 2;
    interface Store {
        int state();
        void save(int state) throws IOException;
    }

    interface Renewal {
        void run() throws IOException;
    }

    static class AuthorizationException extends IOException {
        private static final long serialVersionUID = 1L;

        AuthorizationException(int status) {
            super("Sony authorization required (" + status + ")");
        }
    }

    enum Result { RENEWED, BLOCKED }

    private AuthorizationRecovery() {}

    static Result renew(Store store, Renewal renewal) throws IOException {
        if (store.state() == VERIFY_WRITE) {
            store.save(BLOCKED);
            return Result.BLOCKED;
        }
        if (store.state() == BLOCKED) {
            return Result.BLOCKED;
        }
        // Persist before requesting registration, so a process restart cannot repeat a PIN prompt.
        store.save(BLOCKED);
        try {
            renewal.run();
        } catch (AuthorizationException error) {
            return Result.BLOCKED;
        }
        store.save(VERIFY_WRITE);
        return Result.RENEWED;
    }
}
