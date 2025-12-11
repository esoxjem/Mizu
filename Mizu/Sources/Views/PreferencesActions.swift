import AppKit

@MainActor
final class PreferencesActions {
    static let shared = PreferencesActions()

    private let twitterURL = "https://www.twitter.com/ES0XJEM"
    private let githubURL = "https://www.github.com/esoxjem/Mizu"
    private let notificationSettingsURL = "x-apple.systempreferences:com.apple.Notifications-Settings.extension"

    private init() {}

    func openNotificationSettings() {
        open(urlString: notificationSettingsURL)
    }

    func openTwitter() {
        open(urlString: twitterURL)
    }

    func openGitHub() {
        open(urlString: githubURL)
    }

    func quitApplication() {
        NSApp.terminate(nil)
    }

    func checkForUpdates() {
        UpdaterService.shared.checkForUpdates()
    }

    private func open(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
}
