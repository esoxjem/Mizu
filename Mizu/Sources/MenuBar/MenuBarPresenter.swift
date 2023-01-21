import Cocoa

final class MenuBarPresenter {
    
    private let reminder: Reminder
    private let popover = NSPopover()
    
    init(reminder: Reminder = Reminder()) {
        self.reminder = reminder
    }
    
    func launch() {
        reminder.startTimer()
        buildPopup()
    }
    
    func buildPopup() {
        let vc = PreferencesViewController.newInstance()
        popover.contentViewController = vc
        vc.intervalChanged = { self.resetTimer() }
    }
    
    func statusItemTap(statusItem: NSStatusItem) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.close()
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    private func resetTimer() {
        reminder.reset()
    }
    
}
