# Audio Guardian for Sony Android TV

A sideloaded foreground service that reselects the HDMI audio system after speaker
fallback. It runs entirely on the TV through Sony's loopback JSON-RPC API. No root,
Home Assistant, accessibility service, wake lock, or ongoing ADB connection is needed.
This is the repository's first native Android utility, rather than infrastructure
configuration; its build uses the Android SDK directly without Gradle dependencies.

## Behavior

- Explicitly opt in from the TV launcher. Enabled state and pairing survive reboot
  and APK upgrades signed with the same key.
- Start at `BOOT_COMPLETED` and after package replacement, with a persistent silent
  foreground notification and `START_STICKY` process-restart behavior.
- Suspend polling and recovery in standby. Resume immediately on wake.
- Check every second while awake and immediately on Android audio-device changes.
  Require `speaker` to remain selected for 1 second before the first recovery
  request so Sony can finish its speaker-switch operation. When
  `audioSystem` remains selected, require ARC/eARC to be missing for 2 seconds to
  distinguish a failure from normal audio-device reconfiguration.
- Leave other Sony output selections and connected headphone/Bluetooth/USB audio
  devices alone. Pause recovery before deliberately using the TV speakers or
  powering off the soundbar: reselecting the audio system can wake it through HDMI-CEC.
- After an accepted write, suppress further writes for 5 seconds and require a
  1-second stable healthy state before declaring success. This prevents a transient
  healthy reading during HDMI renegotiation from triggering overlapping recoveries.
  Rejected writes always become eligible for retry 1 second after the failure,
  without exponential backoff. Polling and API response time can add latency.
  Accepted writes retain their 5-second settling window even if Sony subsequently
  reverts to speakers. HDMI handshaking itself can still delay audible recovery.
  Failures appear in the notification, app status, and bounded local diagnostic log.
- Never change volume, eARC settings, inputs, or firmware.

ARC availability and Sony's selected output are useful recovery signals, **not proof
of audible playback**. A genuine spontaneous-dropout test remains necessary.
Android/Sony may kill services; foreground status improves survivability but is not
a guarantee. A force-stopped app cannot restart at boot until opened again. Disabling
the app stops recovery and prevents future boot startup.

## Build and tests

Requires JDK 17, Android SDK platform 34, Build Tools 34.0.0, `zip`, and platform-tools.
Use a persistent private signing key outside the repository so upgrades retain pairing.
Do not commit passwords, signing keys, APKs, or pairing cookies.

```bash
export JAVA_HOME=/path/to/jdk-17
export ANDROID_SDK_ROOT=/path/to/android-sdk
export SIGNING_KEYSTORE="$HOME/.local/share/audio-guardian/signing.p12"
export SIGNING_PASSWORD_FILE="$HOME/.local/share/audio-guardian/signing-password"

# Create these once; protect and back up both files for future APK upgrades.
mkdir -p "$(dirname "$SIGNING_KEYSTORE")"
chmod 700 "$(dirname "$SIGNING_KEYSTORE")"
umask 077
if [[ ! -e "$SIGNING_KEYSTORE" && ! -e "$SIGNING_PASSWORD_FILE" ]]; then
  openssl rand -base64 32 > "$SIGNING_PASSWORD_FILE"
  "$JAVA_HOME/bin/keytool" -genkeypair -storetype PKCS12 \
    -keystore "$SIGNING_KEYSTORE" -storepass:file "$SIGNING_PASSWORD_FILE" \
    -alias audio-guardian -keyalg RSA -keysize 3072 -validity 10000 \
    -dname "CN=Audio Guardian" -noprompt
fi

bash androidtv/audio-guardian/build.sh test
bash androidtv/audio-guardian/build.sh
shellcheck -S warning -x -e SC1091 androidtv/audio-guardian/build.sh
```

The test command needs only Java. The build runs the focused recovery-policy tests
before producing and verifying two signed APKs.

## One-time installation and PIN pairing

The setup APK is a separate, same-signature instrumentation helper. It accesses the
main app's private storage during pairing; it is **not part of the production APK**.
This avoids exporting a credential/control endpoint or needing a keyboard over Sony's
pairing screen. Pair once over ADB, then uninstall the setup APK.

```bash
adb connect 10.10.10.185:5555
adb -s 10.10.10.185:5555 install androidtv/audio-guardian/build/audio-guardian.apk
adb -s 10.10.10.185:5555 install androidtv/audio-guardian/build/audio-guardian-setup.apk
adb -s 10.10.10.185:5555 shell am instrument -w \
  be.timo.audioguardian.setup/be.timo.audioguardian.SetupInstrumentation

# Leave Sony's pairing screen open and substitute the one-time on-screen PIN.
adb -s 10.10.10.185:5555 shell am instrument -w -e pin ON_SCREEN_PIN \
  be.timo.audioguardian.setup/be.timo.audioguardian.SetupInstrumentation
adb -s 10.10.10.185:5555 uninstall be.timo.audioguardian.setup
adb -s 10.10.10.185:5555 shell am start -n be.timo.audioguardian/.MainActivity
```

Choose **Enable / resume recovery**. Pairing cookies stay only in the main app's
private storage with backups disabled. No PIN or cookie is logged. If Sony revokes
authorization, disable recovery and rerun pairing. Reinstall upgrades with `adb install -r`;
uninstalling the main app deletes its pairing and settings. Sony's registered-device
list may retain the Audio Guardian entry after uninstall; remove it from TV settings
if no longer needed.

## TV controls and diagnostics

Open **Audio Guardian** in the TV launcher:

- **Enable / resume recovery** enables boot startup and clears any pause.
- **Pause recovery for 30 minutes** allows temporary deliberate speaker use.
- **Disable recovery (including after reboot)** stops the service.

The screen shows recent events. Logs rotate at 64 KiB with one previous copy.
Diagnostics never include cookies or PINs:

```bash
adb -s 10.10.10.185:5555 shell dumpsys activity service \
  be.timo.audioguardian/.GuardianService
adb -s 10.10.10.185:5555 logcat -d -s AudioGuardian
```

## Reliability validation

1. Enable recovery and return to normal TV viewing; confirm the service is foreground.
2. Select TV speakers manually. After the 1-second settling period and polling, confirm recovery
   is requested and `audioSystem` is selected
   again and `STREAM_MUSIC` routes to `hmdi_arc`. Listen to confirm actual playback.
3. Pause the app, select speakers, and verify it does not override the choice. Resume.
4. Put the TV in standby. Confirm the diagnostic `checks` counter stops increasing
   and no recovery requests are made. Wake the TV and verify monitoring resumes.
5. Reboot the TV (not just standby), reconnect ADB, and check the log for
   `BOOT_COMPLETED`, a new foreground service process, and resumed monitoring.
   Sony can deliver the app's boot broadcast tens of seconds after the global boot
   property is set; allow up to 3 minutes and verify the service itself exists.
6. Repeat speaker fallback after wake/reboot, then observe a genuine spontaneous failure.

Keep eARC enabled throughout. Standby and reboot tests interrupt viewing and must be
performed only with the owner's approval.
