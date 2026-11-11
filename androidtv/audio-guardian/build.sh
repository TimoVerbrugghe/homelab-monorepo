#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
if [[ -n "${JAVA_HOME:-}" ]]; then
  export PATH="$JAVA_HOME/bin:$PATH"
fi

mkdir -p build/tests
javac --release 8 -Xlint:all -Werror -d build/tests \
  src/be/timo/audioguardian/RecoveryPolicy.java \
  tests/be/timo/audioguardian/RecoveryPolicyTest.java
java -cp build/tests be.timo.audioguardian.RecoveryPolicyTest
if [[ "${1:-}" == "test" ]]; then
  exit 0
fi

: "${ANDROID_SDK_ROOT:?Set ANDROID_SDK_ROOT to the Android SDK directory}"
: "${SIGNING_KEYSTORE:?Set SIGNING_KEYSTORE to a persistent keystore outside this repository}"
: "${SIGNING_PASSWORD_FILE:?Set SIGNING_PASSWORD_FILE to its protected password file}"
tools="$ANDROID_SDK_ROOT/build-tools/${BUILD_TOOLS_VERSION:-34.0.0}"
android="$ANDROID_SDK_ROOT/platforms/android-34/android.jar"
mkdir -p build/app-classes build/app-dex build/setup-classes build/setup-dex
sources=()
while IFS= read -r -d '' source; do
  sources+=("$source")
done < <(find src -name '*.java' -print0)
javac --release 8 -Xlint:all -Werror -cp "$android" -d build/app-classes "${sources[@]}"
classes=()
while IFS= read -r -d '' class; do
  classes+=("$class")
done < <(find build/app-classes -name '*.class' -print0)
"$tools/d8" --min-api 26 --lib "$android" --output build/app-dex "${classes[@]}"
"$tools/aapt" package -f -M AndroidManifest.xml -S res -I "$android" -F build/app-unsigned.apk
(cd build/app-dex && zip -q ../app-unsigned.apk classes.dex)
"$tools/zipalign" -f 4 build/app-unsigned.apk build/app-aligned.apk
"$tools/apksigner" sign --ks "$SIGNING_KEYSTORE" --ks-pass "file:$SIGNING_PASSWORD_FILE" \
  --out build/audio-guardian.apk build/app-aligned.apk
"$tools/apksigner" verify build/audio-guardian.apk

javac --release 8 -Xlint:all -Werror -cp "$android:build/app-classes" \
  -d build/setup-classes tests/be/timo/audioguardian/SetupInstrumentation.java
classes=()
while IFS= read -r -d '' class; do
  classes+=("$class")
done < <(find build/setup-classes -name '*.class' -print0)
"$tools/d8" --min-api 26 --lib "$android" --lib build/app-classes \
  --output build/setup-dex "${classes[@]}"
"$tools/aapt" package -f -M tests/AndroidManifest.xml -I "$android" -F build/setup-unsigned.apk
(cd build/setup-dex && zip -q ../setup-unsigned.apk classes.dex)
"$tools/zipalign" -f 4 build/setup-unsigned.apk build/setup-aligned.apk
"$tools/apksigner" sign --ks "$SIGNING_KEYSTORE" --ks-pass "file:$SIGNING_PASSWORD_FILE" \
  --out build/audio-guardian-setup.apk build/setup-aligned.apk
"$tools/apksigner" verify build/audio-guardian-setup.apk
printf 'Built and verified: %s/build/audio-guardian{,-setup}.apk\n' "$PWD"
