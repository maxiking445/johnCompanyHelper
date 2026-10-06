# Android release builds

`workflows/android-build.yml` is a reusable workflow, also runnable manually.
`release.yml` calls it after tests. Its `android-<release_tag>` artifact is
downloaded alongside desktop builds, included in SHA256SUMS.txt and attached
to the GitHub Release as `JohnCompanyHelper-<release_tag>-android.apk`.
A failed Android build prevents release publication.

Uses existing actions: [setup-godot](https://github.com/chickensoft-games/setup-godot)
and [setup-android](https://github.com/android-actions/setup-android).
Android uses Godot 4.7.2 (matching the locally tested APK), Java 17 and SDK 35.
Desktop workflows retain their existing Godot version.
The APK contains ARM64 and x86_64 as configured in the Android export preset.

## Temporary debug signing (no secrets required)

The workflow generates a fresh Android debug keystore for each run (alias
`androiddebugkey`, passwords `android`) and signs the exported release-mode
APK with it. Signature and alignment are verified before upload. No GitHub
secrets or manual signing setup are needed. The keystore is deleted after use.

These APKs are intended for testing. Each build uses a different signing key:
users must uninstall an earlier build before installing another one, which
removes its app data. The same applies when switching from a local Godot build.
For production releases and in-place updates, replace this temporary setup
with a persistent private release key stored in GitHub secrets.

Version names come from the release input/tag; version codes are
`major * 1000000 + minor * 1000 + patch` (minor and patch must be below 1000).
Use increasing versions for upgrades. CI-only export configuration changes
are not committed back to the repository.

For local emulator testing use a standard Android 35 x86_64 image. The
special 16-KB image previously crashed in the Android native library loader;
APK signature/alignment checks do not replace runtime testing on that image.
