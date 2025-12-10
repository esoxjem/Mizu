import Foundation
import SwiftUI
import LaunchAtLogin

/// Central settings store using @AppStorage for automatic UserDefaults persistence.
/// Keys match existing UserDefaults keys for backward compatibility.
@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    /// Raw interval value (0-4) stored in UserDefaults
    @AppStorage("interval") var intervalRawValue: Int = ReminderInterval.oneHour.rawValue

    /// Whether notification sound is enabled
    @AppStorage("sound") var isSoundEnabled: Bool = true

    /// Whether to launch at login - synced with LaunchAtLogin framework
    @AppStorage("startup") var isLaunchAtLoginEnabled: Bool = false {
        didSet {
            LaunchAtLogin.isEnabled = isLaunchAtLoginEnabled
        }
    }

    /// Tracks whether notification permission has been requested
    @AppStorage("hasRequestedNotificationPermission") var hasRequestedPermission: Bool = false

    /// Type-safe accessor for the selected interval
    var selectedInterval: ReminderInterval {
        get { ReminderInterval(rawValue: intervalRawValue) ?? .oneHour }
        set { intervalRawValue = newValue.rawValue }
    }

    private init() {
        // Sync LaunchAtLogin state on initialization to ensure consistency
        LaunchAtLogin.isEnabled = isLaunchAtLoginEnabled
    }
}
