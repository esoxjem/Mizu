import Cocoa

final class MenuBar: NSObject {
	
	private let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
	private var timer: Timer?
	
	var eventMonitor: EventMonitor?
	
	func launch() {
		monitorOutsideClicks()
		initStatusBar()
		startReminderTimer()
	}
	
	private func monitorOutsideClicks() {
		eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
			if let strongSelf = self {
				strongSelf.eventMonitor?.stop()
			}
		}
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
							  action: #selector(showPopover(_:)),
							  keyEquivalent: "")
		item.target = self
		menu.addItem(item)
		menu.addItem(NSMenuItem.separator())
		menu.addItem(NSMenuItem(title: "Quit",
								action: #selector(NSApplication.terminate(_:)),
								keyEquivalent: ""))
		return menu
	}
	
	@objc func showPopover(_ sender : NSMenuItem?) {
		if let button = statusItem.button {
			let popover = NSPopover()
			let vc = PreferencesViewController.newInstance()
			popover.contentViewController = vc
			vc.intervalChanged = { self.resetTimer() }
			popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
			eventMonitor?.start()
		}
	}
	
	private func startReminderTimer() {
		let intervalInSecs = Interval().seconds()
		timer = Timer.scheduledTimer(timeInterval: intervalInSecs,
							 target: self,
							 selector: #selector(showNotification),
							 userInfo: nil, repeats: true)
	}
	
	private func resetTimer() {
		timer?.invalidate()
		startReminderTimer()
	}
	
	@objc private func showNotification() {
		let notification = NSUserNotification()
		notification.title = "Time to drink water"
		notification.informativeText = "It's been \(Interval().string()) since your last cup."
		notification.soundName = NSUserNotificationDefaultSoundName
		notification.hasActionButton = true
		notification.otherButtonTitle = "Dismiss"
		notification.actionButtonTitle = "OK"
		
		let notificationCenter = NSUserNotificationCenter.default
		notificationCenter.deliver(notification)
	}
}
