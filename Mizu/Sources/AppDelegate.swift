import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupNotificationDelegate()
        startApplication()
    }

    private func setupNotificationDelegate() {
        _ = NotificationDelegate.shared
    }

    private func startApplication() {
        Task { @MainActor in
            await requestNotificationPermission()
            initializeMenuBar()
        }
    }

    @MainActor
    private func requestNotificationPermission() async {
        _ = await NotificationActor.shared.requestPermissionIfNeeded()
    }

    @MainActor
    private func initializeMenuBar() {
        menuBarController = MenuBarController()
    }
}
