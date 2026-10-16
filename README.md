# Mizu 水 
macOS reminder app to drink water. Reach your daily hydration goals easily ;)

![Screenshot](/Assets/screenshot.png) 

Debug builds are **Mizu Dev** (`com.esoxjem.mizu.dev`). They run alongside the
production app with separate settings, notification permissions, and login-item
registration. A **Dev** label in the menu bar identifies the development app;
production updates are disabled in this variant.

Notifications default to persistent alerts that stay visible until dismissed.
If macOS has already saved a temporary style, open **System Settings →
Notifications → Mizu** (or **Mizu Dev**) and choose **Persistent** (called
**Alerts** on older macOS versions).

In Xcode, run the `Mizu` scheme with the Debug configuration, or build and launch
and refresh the installed dev app from the command line:

```bash
python3 scripts/refresh_dev_app.py
```

This rebuilds, replaces, and restarts `~/Applications/Mizu Dev.app`. The local
release process runs the same command after each verified release.

Release builds and archives remain **Mizu** (`com.esoxjem.mizu`). Follow the
[release process](docs/RELEASE.md) for distribution.

Run the tests with:

```bash
xcodebuild -project Mizu.xcodeproj -scheme Mizu -destination 'platform=macOS' test
```

The hostless test target compiles the production sources without the app entry points.
Reminder tests advance a manual clock; they never wait for real reminder intervals.

Test the local dev refresh script with:

```bash
python3 -m unittest discover -s scripts/tests -v
```
