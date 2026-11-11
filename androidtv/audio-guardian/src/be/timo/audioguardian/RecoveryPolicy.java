package be.timo.audioguardian;

final class RecoveryPolicy {
    static final long VERIFY_MS = 5000;
    static final long HEALTHY_STABLE_MS = 1000;
    static final long ARC_MISSING_MS = 2000;
    static final long SPEAKER_SETTLE_MS = 1000;
    static final long RETRY_MS = 1000;

    enum Decision { WAIT, HEALTHY, RECOVER, VERIFYING, RECOVERED, OTHER_OUTPUT }

    private long pendingSince = -1;
    private long healthySince = -1;
    private long arcMissingSince = -1;
    private long speakerSince = -1;
    private long settleUntil;
    private long nextAttemptAt;

    void reset() {
        pendingSince = -1;
        healthySince = -1;
        arcMissingSince = -1;
        speakerSince = -1;
    }

    void failed(long now) {
        pendingSince = -1;
        healthySince = -1;
        settleUntil = 0;
        nextAttemptAt = now + RETRY_MS;
    }

    Decision observe(long now, String output, boolean arcAvailable, boolean otherDevice) {
        if (otherDevice || (!"speaker".equals(output) && !"audioSystem".equals(output))) {
            reset();
            return Decision.OTHER_OUTPUT;
        }
        if ("audioSystem".equals(output) && arcAvailable) {
            boolean recovered = pendingSince >= 0;
            if (recovered) {
                if (healthySince < 0) {
                    healthySince = now;
                }
                if (now - healthySince < HEALTHY_STABLE_MS) {
                    return Decision.VERIFYING;
                }
            }
            reset();
            nextAttemptAt = settleUntil;
            return recovered ? Decision.RECOVERED : Decision.HEALTHY;
        }
        healthySince = -1;
        if ("speaker".equals(output)) {
            if (speakerSince < 0) {
                speakerSince = now;
            }
        } else {
            speakerSince = -1;
        }
        if (pendingSince >= 0) {
            if (now < settleUntil) {
                return Decision.VERIFYING;
            }
            pendingSince = -1;
        }
        if ("audioSystem".equals(output)) {
            if (arcMissingSince < 0) {
                arcMissingSince = now;
            }
            if (now - arcMissingSince < ARC_MISSING_MS) {
                return Decision.WAIT;
            }
        } else {
            arcMissingSince = -1;
            if (now - speakerSince < SPEAKER_SETTLE_MS) {
                return Decision.WAIT;
            }
        }
        if (now < nextAttemptAt || now < settleUntil) {
            return Decision.WAIT;
        }
        return Decision.RECOVER;
    }

    void attempted(long now) {
        nextAttemptAt = now + RETRY_MS;
    }

    void accepted(long now) {
        pendingSince = now;
        healthySince = -1;
        arcMissingSince = -1;
        settleUntil = now + VERIFY_MS;
    }
}
