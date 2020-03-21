import Foundation


class Reminder {
	
	static func show() {
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
