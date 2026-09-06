# My First App — Kotlin/Compose Android starter (cloud-built)

This project is set up for **developing Android apps on a low-spec machine**
(2 cores / 3.7 GB RAM): you **edit locally, build in the cloud, and test on a
real phone**. Android Studio and the Android emulator are never needed.

```
 edit in VS Code          build in the cloud              test on your phone
┌──────────────┐   push   ┌───────────────────────┐  APK  ┌─────────────┐
│  this machine│ ───────► │ Codespace / Gitpod /  │ ────► │ adb install │
│  (no SDK!)   │          │ GitHub Actions        │ download│ (USB/Wi-Fi)│
└──────────────┘          └───────────────────────┘       └─────────────┘
```

## What's in the repo

| Path | Purpose |
|---|---|
| `app/` | The app: Kotlin + Jetpack Compose (Material 3), `minSdk 26`, `targetSdk 36` |
| `gradle/libs.versions.toml` | Version catalog (AGP 8.10.0, Kotlin 2.2.0, Compose BOM) |
| `.devcontainer/` | GitHub Codespaces config (JDK 17 + Android SDK auto-install) |
| `scripts/setup-android-sdk.sh` | Installs cmdline-tools, platform 36, build-tools 36.0.0 |
| `.gitpod.yml` | Alternative: Gitpod |
| `.github/workflows/android-build.yml` | Builds an APK artifact on every push (backup/validation) |

## 1. One-time: put it on GitHub

```bash
cd my-first-app
git push -u origin main        # if a remote was already added by Cline
# or from scratch:
gh repo create my-first-app --private --source=. --push
```

## 2. One-time: prepare your phone

1. Settings → About phone → tap **Build number** 7× to enable Developer options.
2. Developer options → enable **USB debugging** (and **Wireless debugging**).

## 3. Daily loop

1. **Edit** the app locally (VS Code) — e.g. `app/src/main/java/com/example/myfirstapp/MainActivity.kt`.
2. **Commit + push:**
   ```bash
   git add -A && git commit -m "wip" && git push
   ```
3. **Build in a Codespace** (first open runs the SDK setup, ~5 min):
   - Web: repo → green **Code** button → **Codespaces** → *Create codespace on main*.
   - CLI: `gh codespace create -R JLSed/my-first-app -b main -m basicLinux32gb`
   Then in the codespace terminal:
   ```bash
   ./gradlew assembleDebug
   # APK at app/build/outputs/apk/debug/app-debug.apk
   ```
   First build ~10 min; later builds ~1–3 min.
4. **Download the APK** to this machine:
   - VS Code explorer → right-click `app-debug.apk` → *Download…*, or
   - `gh codespace cp -c <name> remote:/home/vscode/my-first-app/app/build/outputs/apk/debug/app-debug.apk .`
5. **Install on the phone** (only `adb` is needed locally — already installed via Nix):
   ```bash
   adb devices            # plug phone in via USB, accept the prompt on the phone
   adb install -r app-debug.apk
   ```
   **Wi-Fi instead of USB** (avoids NixOS udev permission issues):
   Phone → Developer options → Wireless debugging → *Pair device with code*:
   ```bash
   adb pair <phone-ip>:<pair-port>      # enter the 6-digit code shown on the phone
   adb connect <phone-ip>:<debug-port>
   adb install -r app-debug.apk
   ```
   If USB shows *no permissions* on NixOS, either use wireless or add
   `pkgs.android-udev-rules` to `services.udev.packages` (needs a system rebuild).

**Faster loop without a codespace:** the GitHub Action builds on every push —
grab the APK from the run's **Artifacts** section, then `adb install -r`.

## Costs

- **Codespaces:** free tier = 120 core-hours + 15 GB storage/month → ~60 h on the
  2-core `basicLinux32gb` machine. Codespaces auto-stop after 30 min idle; delete
  unused ones at github.com/codespaces.
- **GitHub Actions:** free for public repos; private repos get 2,000 min/month
  (~20 min per build here).
- **Gitpod:** free 50 h/month on the same repo (uses `.gitpod.yml`).

## Why not build locally?

This machine (Celeron N4020, 2×1.1 GHz, 3.7 GB RAM, eMMC) can't run
Gradle + Kotlin compiler + Android Studio comfortably — that's why the SDK is
deliberately *not* installed here. If you're ever curious, you can try a build
inside `nix-shell` with a JDK, but expect heavy swapping.

## Renaming the app

The placeholder id is `com.example.myfirstapp`. To rename: change
`rootProject.name` in `settings.gradle.kts`, `namespace`/`applicationId` in
`app/build.gradle.kts`, the `app_name` string, and the package folder
`app/src/main/java/com/example/myfirstapp/`.
