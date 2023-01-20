import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let menubar = MenuBar()
    
    func applicationDidFinishLaunching(_: Notification) {
        menubar.launch()
    }
}
