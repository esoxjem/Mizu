# Mizu 水 
macOS reminder app to drink water. Reach your daily hydration goals easily ;)

![Screenshot](/Assets/screenshot.png) 

Debug builds are **Mizu Dev** (`com.esoxjem.mizu.dev`). They run alongside the
production app with separate settings, notification permissions, and login-item
registration. A **Dev** label in the menu bar identifies the development app;
production updates are disabled in this variant.

In Xcode, run the `Mizu` scheme with the Debug configuration, or build and launch
from the command line:

```bash
xcodebuild -project Mizu.xcodeproj -scheme Mizu -configuration Debug -derivedDataPath build/dev build
open "build/dev/Build/Products/Debug/Mizu Dev.app"
```

Quit Mizu Dev before relaunching a rebuilt copy from the command line.

Release builds and archives remain **Mizu** (`com.esoxjem.mizu`). Follow the
[release process](docs/RELEASE.md) for distribution.

Run the tests with:

```bash
xcodebuild -project Mizu.xcodeproj -scheme Mizu -destination 'platform=macOS' test
```

The hostless test target compiles the production sources without the app entry points.
Reminder tests advance a manual clock; they never wait for real reminder intervals.
