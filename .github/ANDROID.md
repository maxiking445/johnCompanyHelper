# Android build

The Android release build is kept in a separate reusable workflow and is called by the release workflow.

## Local setup

Run `scripts/setup_android_build.sh` from the repository root. It installs the Android SDK components required by the project and prints the Java SDK and Android SDK paths for Godot's Android export settings.

The checked-in Android preset targets Android API 35 and supports ARM64 and x86_64. The project uses Godot's mobile Compatibility renderer for Android.

## CI and releases

The Android workflow uses Godot 4.7.2, Java 17, Android API 35, and a temporary debug keystore. The signed APK is uploaded as an artifact and the release workflow attaches it to the GitHub Release as:

`JohnCompanyHelper-<tag>-android.apk`

Because a new debug keystore is generated for every run, uninstall an older debug build before installing a new one. A persistent production keystore should be configured before publishing production updates.
