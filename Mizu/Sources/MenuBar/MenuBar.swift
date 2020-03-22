import Cocoa

final class MenuBar: NSObject {
    
    private let presenter = MenuBarPresenter()
    private let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    func launch() {
        initStatusBar()
        presenter.launch()
    }
    
    private func initStatusBar() {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarImage"))
        }
        
        statusItem.menu = createMenu()
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        let item = NSMenuItem(title: "Preferences",
                              action: #selector(prefClicked(_:)),
                              keyEquivalent: "")
        item.target = self
        menu.addItem(item)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: ""))
        return menu
    }
    
    @objc func prefClicked(_ sender : NSMenuItem?) {
        presenter.prefClicked(statusItem: statusItem)
    }
    
}
