import Cocoa

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var reminderService: ReminderService?

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
        _ = UpdaterService.shared
        let reminderService = ReminderService(settings: .shared)
        self.reminderService = reminderService
        reminderService.start()
        menuBarController = MenuBarController()
    }

    func applicationWillTerminate(_ notification: Notification) {
        reminderService?.stop()
    }
}
