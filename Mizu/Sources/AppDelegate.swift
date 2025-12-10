import Cocoa

/// App delegate that sets up the menu bar controller and notification delegate.
/// The @main attribute is now on MizuApp, so @NSApplicationMain is removed.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize notification delegate to handle foreground notifications
        _ = NotificationDelegate.shared

        // Request notification permission and start the menu bar
        Task { @MainActor in
            _ = await NotificationActor.shared.requestPermissionIfNeeded()
            menuBarController = MenuBarController()
        }
    }
}
