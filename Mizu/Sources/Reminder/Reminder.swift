import Foundation

class Reminder {
    
    private var timer: Timer?
    
    func startTimer() {
        let intervalInSecs = Interval().seconds()
        timer = Timer.scheduledTimer(timeInterval: intervalInSecs,
                                     target: self,
                                     selector: #selector(showNotification),
                                     userInfo: nil, repeats: true)
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
    
    func reset() {
        timer?.invalidate()
        startTimer()
    }
}
