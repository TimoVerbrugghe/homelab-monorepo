package be.timo.audioguardian;

import java.io.IOException;

public final class AuthorizationRecoveryTest {
    public static void main(String[] args) throws IOException {
        MemoryStore store = new MemoryStore();
        int[] calls = {0};
        AuthorizationRecovery.Renewal success = () -> {
            calls[0]++;
            expect(store.state(), AuthorizationRecovery.BLOCKED);
        };
        expect(AuthorizationRecovery.renew(store, success),
                AuthorizationRecovery.Result.RENEWED);
        expect(store.state(), AuthorizationRecovery.VERIFY_WRITE);
        expect(AuthorizationRecovery.renew(store, success),
                AuthorizationRecovery.Result.BLOCKED);
        expect(AuthorizationRecovery.renew(store, success),
                AuthorizationRecovery.Result.BLOCKED);
        expect(calls[0], 1);

        store.save(AuthorizationRecovery.READY);
        expect(AuthorizationRecovery.renew(store, () -> {
            throw new AuthorizationRecovery.AuthorizationException(401);
        }), AuthorizationRecovery.Result.BLOCKED);
        expect(store.state(), AuthorizationRecovery.BLOCKED);

        store.save(AuthorizationRecovery.READY);
        try {
            AuthorizationRecovery.renew(store, () -> {
                throw new IOException("connection failed");
            });
            throw new AssertionError("Expected renewal failure");
        } catch (IOException expected) {
            expect(expected.getMessage(), "connection failed");
        }
        expect(store.state(), AuthorizationRecovery.BLOCKED);
        expect(AuthorizationRecovery.renew(store, success),
                AuthorizationRecovery.Result.BLOCKED);
        expect(calls[0], 1);

        store.save(AuthorizationRecovery.READY);
        expect(AuthorizationRecovery.renew(store, success),
                AuthorizationRecovery.Result.RENEWED);
        store.save(AuthorizationRecovery.READY);
        expect(AuthorizationRecovery.renew(store, success),
                AuthorizationRecovery.Result.RENEWED);
        expect(calls[0], 3);
        System.out.println("AuthorizationRecovery tests passed.");
    }

    private static void expect(Object actual, Object expected) {
        if (!expected.equals(actual)) {
            throw new AssertionError("Expected " + expected + " but got " + actual);
        }
    }

    private static final class MemoryStore implements AuthorizationRecovery.Store {
        private int state = AuthorizationRecovery.READY;

        @Override
        public int state() {
            return state;
        }

        @Override
        public void save(int newState) {
            state = newState;
        }
    }
}
