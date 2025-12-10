import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let menubar = MenuBar()

    func applicationDidFinishLaunching(_: Notification) {
        _ = NotificationManager.shared
        menubar.launch()
    }
}
