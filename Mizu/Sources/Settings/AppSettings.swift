import Foundation
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("interval") var intervalRawValue: Int = ReminderInterval.oneHour.rawValue
    @AppStorage("sound") var isSoundEnabled: Bool = true
    @AppStorage("hasRequestedNotificationPermission") var hasRequestedPermission: Bool = false

    @AppStorage("startup") var isLaunchAtLoginEnabled: Bool = false {
        didSet { syncLaunchAtLoginState() }
    }

    var selectedInterval: ReminderInterval {
        get { ReminderInterval(rawValue: intervalRawValue) ?? .oneHour }
        set { intervalRawValue = newValue.rawValue }
    }

    private init() {
        syncLaunchAtLoginState()
    }

    private func syncLaunchAtLoginState() {
        if isLaunchAtLoginEnabled {
            LaunchAtLoginService.shared.enable()
        } else {
            LaunchAtLoginService.shared.disable()
        }
    }
}
