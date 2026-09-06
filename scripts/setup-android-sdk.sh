#!/usr/bin/env bash
# Installs the Android SDK (commandline-tools + platform 36 + build-tools)
# into $ANDROID_HOME. Runs in GitHub Codespaces / Gitpod on first open.
set -euo pipefail

SDK="${ANDROID_HOME:-$HOME/android-sdk}"
CLT_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

if [ ! -d "$SDK/cmdline-tools/latest/bin" ]; then
    echo ">> Downloading Android commandline-tools..."
    # 'unzip' is missing on some minimal images
    command -v unzip >/dev/null || (sudo apt-get update -qq && sudo apt-get install -y -qq unzip)
    mkdir -p "$SDK/cmdline-tools"
    TMP="$(mktemp -d)"
    curl -fsSL -o "$TMP/clt.zip" "$CLT_URL"
    unzip -q "$TMP/clt.zip" -d "$TMP"
    mv "$TMP/cmdline-tools" "$SDK/cmdline-tools/latest"
    rm -rf "$TMP"
fi

echo ">> Accepting SDK licenses..."
yes | "$SDK/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null || true

echo ">> Installing platform-tools, platforms;android-36, build-tools;36.0.0 ..."
"$SDK/cmdline-tools/latest/bin/sdkmanager" --install \
    "platform-tools" "platforms;android-36" "build-tools;36.0.0" >/dev/null

echo ">> Android SDK ready at: $SDK"
