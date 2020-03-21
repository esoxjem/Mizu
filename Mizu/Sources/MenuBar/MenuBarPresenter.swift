import Cocoa

final class MenuBarPresenter {
	
	private var timer: Timer?
	
	func launch() {
		startReminderTimer()
	}
	
	private func startReminderTimer() {
		let intervalInSecs = Interval().seconds()
		timer = Timer.scheduledTimer(timeInterval: intervalInSecs,
							 target: self,
							 selector: #selector(showNotification),
							 userInfo: nil, repeats: true)
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
		timer?.invalidate()
		startReminderTimer()
	}
	
	@objc private func showNotification() {
		Reminder.show()
	}
	
}
