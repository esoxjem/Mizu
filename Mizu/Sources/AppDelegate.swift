import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let menubar = MenuBar()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menubar.launch()
    }
}
