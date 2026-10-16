# Mizu 水 
macOS reminder app to drink water. Reach your daily hydration goals easily ;)

![Screenshot](/Assets/screenshot.png) 

Run the tests with:

```bash
xcodebuild -project Mizu.xcodeproj -scheme Mizu -destination 'platform=macOS' test
```

The hostless test target compiles the production sources without the app entry points.
Reminder tests advance a manual clock; they never wait for real reminder intervals.
