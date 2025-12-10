import Foundation
import UserNotifications

/// Handles notification center delegate callbacks.
/// Actors cannot conform to Objective-C protocols, so this separate class
/// handles UNUserNotificationCenterDelegate responsibilities.
@MainActor
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    /// Called when a notification is about to be presented while the app is in foreground.
    /// Returns banner and sound options to show notifications even when the app is active.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }

    /// Called when the user interacts with a notification.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // Handle notification tap if needed in the future
    }
}
