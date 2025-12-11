import Foundation
import SwiftUI

/// Central settings store using @AppStorage for automatic UserDefaults persistence.
/// Keys match existing UserDefaults keys for backward compatibility.
@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    /// Raw interval value (0-4) stored in UserDefaults
    @AppStorage("interval") var intervalRawValue: Int = ReminderInterval.oneHour.rawValue

    /// Whether notification sound is enabled
    @AppStorage("sound") var isSoundEnabled: Bool = true

    /// Whether to launch at login - synced with SMAppService
    @AppStorage("startup") var isLaunchAtLoginEnabled: Bool = false {
        didSet {
            if isLaunchAtLoginEnabled {
                LaunchAtLoginService.shared.enable()
            } else {
                LaunchAtLoginService.shared.disable()
            }
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
        // Sync SMAppService state on initialization to ensure consistency
        if isLaunchAtLoginEnabled {
            LaunchAtLoginService.shared.enable()
        }
    }
}
