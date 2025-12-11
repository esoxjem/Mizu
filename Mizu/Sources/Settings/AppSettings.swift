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

    @AppStorage("automaticallyCheckForUpdates") var isAutoUpdateEnabled: Bool = true {
        didSet { syncAutoUpdateState() }
    }

    var selectedInterval: ReminderInterval {
        get { ReminderInterval(rawValue: intervalRawValue) ?? .oneHour }
        set { intervalRawValue = newValue.rawValue }
    }

    private init() {
        syncLaunchAtLoginState()
        syncAutoUpdateState()
    }

    private func syncLaunchAtLoginState() {
        if isLaunchAtLoginEnabled {
            LaunchAtLoginService.shared.enable()
        } else {
            LaunchAtLoginService.shared.disable()
        }
    }

    private func syncAutoUpdateState() {
        UpdaterService.shared.automaticallyChecksForUpdates = isAutoUpdateEnabled
    }
}
