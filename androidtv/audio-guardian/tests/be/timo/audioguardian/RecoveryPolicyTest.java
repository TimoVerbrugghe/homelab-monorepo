package be.timo.audioguardian;

public final class RecoveryPolicyTest {
    public static void main(String[] args) {
        RecoveryPolicy policy = new RecoveryPolicy();
        expect(policy.observe(0, "speaker", false, false), RecoveryPolicy.Decision.WAIT);
        expect(policy.observe(999, "speaker", false, false), RecoveryPolicy.Decision.WAIT);
        expect(policy.observe(1000, "speaker", false, false), RecoveryPolicy.Decision.RECOVER);
        policy.attempted(1000);
        policy.accepted(1000);
        expect(policy.observe(2000, "audioSystem", true, false),
                RecoveryPolicy.Decision.VERIFYING);
        expect(policy.observe(3000, "audioSystem", true, false),
                RecoveryPolicy.Decision.RECOVERED);
        expect(policy.observe(3001, "speaker", false, false), RecoveryPolicy.Decision.WAIT);
        expect(policy.observe(6000, "speaker", false, false), RecoveryPolicy.Decision.RECOVER);
        policy.reset();
        expect(policy.observe(6000, "audioSystem", false, false),
                RecoveryPolicy.Decision.WAIT);
        expect(policy.observe(8000, "audioSystem", false, false),
                RecoveryPolicy.Decision.RECOVER);
        expect(policy.observe(8001, "speaker", false, true),
                RecoveryPolicy.Decision.OTHER_OUTPUT);
        expect(policy.observe(8002, "headphone", false, false),
                RecoveryPolicy.Decision.OTHER_OUTPUT);

        policy = new RecoveryPolicy();
        expect(policy.observe(0, "speaker", false, false), RecoveryPolicy.Decision.WAIT);
        long now = 1000;
        for (int attempt = 0; attempt < 10; attempt++) {
            expect(policy.observe(now, "speaker", false, false),
                    RecoveryPolicy.Decision.RECOVER);
            policy.attempted(now);
            long rejectedAt = now + 200;
            policy.failed(rejectedAt);
            expect(policy.observe(rejectedAt + 999, "speaker", false, false),
                    RecoveryPolicy.Decision.WAIT);
            now = rejectedAt + 1000;
            expect(policy.observe(now, "speaker", false, false),
                    RecoveryPolicy.Decision.RECOVER);
        }
        expect(policy.observe(now, "audioSystem", true, false), RecoveryPolicy.Decision.HEALTHY);
        expect(policy.observe(now + 1, "speaker", false, false), RecoveryPolicy.Decision.WAIT);
        expect(policy.observe(now + 1001, "speaker", false, false),
                RecoveryPolicy.Decision.RECOVER);

        policy = new RecoveryPolicy();
        policy.attempted(0);
        policy.accepted(0);
        expect(policy.observe(1000, "speaker", false, false),
                RecoveryPolicy.Decision.VERIFYING);
        expect(policy.observe(4999, "speaker", false, false),
                RecoveryPolicy.Decision.VERIFYING);
        expect(policy.observe(5000, "speaker", false, false),
                RecoveryPolicy.Decision.RECOVER);

        // Sony briefly reports healthy routing before ARC drops again in the same switch.
        policy = new RecoveryPolicy();
        policy.attempted(0);
        policy.accepted(0);
        expect(policy.observe(200, "audioSystem", true, false),
                RecoveryPolicy.Decision.VERIFYING);
        expect(policy.observe(800, "speaker", false, false),
                RecoveryPolicy.Decision.VERIFYING);
        expect(policy.observe(1500, "audioSystem", true, false),
                RecoveryPolicy.Decision.VERIFYING);
        expect(policy.observe(2499, "audioSystem", true, false),
                RecoveryPolicy.Decision.VERIFYING);
        expect(policy.observe(2500, "audioSystem", true, false),
                RecoveryPolicy.Decision.RECOVERED);
        expect(policy.observe(3000, "audioSystem", false, false), RecoveryPolicy.Decision.WAIT);
        expect(policy.observe(4500, "audioSystem", true, false), RecoveryPolicy.Decision.HEALTHY);

        policy = new RecoveryPolicy();
        expect(policy.observe(0, "speaker", false, false), RecoveryPolicy.Decision.WAIT);
        expect(policy.observe(500, "audioSystem", true, false), RecoveryPolicy.Decision.HEALTHY);
        expect(policy.observe(900, "speaker", false, false), RecoveryPolicy.Decision.WAIT);
        expect(policy.observe(1899, "speaker", false, false), RecoveryPolicy.Decision.WAIT);
        expect(policy.observe(1900, "speaker", false, false), RecoveryPolicy.Decision.RECOVER);
        System.out.println("RecoveryPolicy tests passed: one-second speaker settling, delayed ARC, "
                + "alternate outputs, fixed one-second rejected-write retries, "
                + "transient routing flaps.");
    }

    private static void expect(RecoveryPolicy.Decision actual, RecoveryPolicy.Decision expected) {
        if (actual != expected) {
            throw new AssertionError("Expected " + expected + " but got " + actual);
        }
    }
}
