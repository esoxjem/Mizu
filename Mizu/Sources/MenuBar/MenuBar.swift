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
            button.action = #selector(statusItemTap(_:))
            button.target = self
        }
    }
    
    @objc private func statusItemTap(_ sender: NSStatusBarButton) {
        presenter.statusItemTap(statusItem: statusItem)
    }
}
