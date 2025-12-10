import Foundation

class Reminder {

    private var timer: Timer?
    private let preferences = Preferences()
    private let notificationManager = NotificationManager.shared

    func startTimer() {
        let intervalInSecs = Interval().seconds()
        timer = Timer.scheduledTimer(timeInterval: intervalInSecs,
                                     target: self,
                                     selector: #selector(showNotification),
                                     userInfo: nil, repeats: true)
    }

    @objc private func showNotification() {
        notificationManager.deliverNotification(
            title: "Time to drink water",
            body: "It's been \(Interval().string()) since your last glass.",
            withSound: preferences.isSoundEnabled()
        )
    }

    func reset() {
        timer?.invalidate()
        startTimer()
    }
}
