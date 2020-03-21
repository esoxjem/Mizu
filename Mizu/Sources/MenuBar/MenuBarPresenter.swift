import Cocoa

final class MenuBarPresenter {
	
	private let reminder: Reminder
	
	init(reminder: Reminder = Reminder()) {
		self.reminder = reminder
	}
	
	func launch() {
		reminder.startTimer()
	}
	
	func prefClicked(statusItem: NSStatusItem) {
		if let button = statusItem.button {
			let popover = NSPopover()
			let vc = PreferencesViewController.newInstance()
			popover.contentViewController = vc
			vc.intervalChanged = { self.resetTimer() }
			popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
		}
	}
	
	private func resetTimer() {
		reminder.reset()
	}
	
}
