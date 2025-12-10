import SwiftUI
import AppKit

/// SwiftUI preferences view replacing the NIB-based PreferencesViewController.
/// Matches the original layout: icon, title, slider, toggles, and settings menu.
struct PreferencesView: View {
    @ObservedObject var settings: AppSettings
    var onIntervalChanged: (() -> Void)?

    // Avenir Next fonts
    private let titleFont = Font(NSFont(name: "AvenirNext-UltraLight", size: 24)!)
    private let bodyFont = Font(NSFont(name: "AvenirNext-Medium", size: 13)!)
    private let captionFont = Font(NSFont(name: "AvenirNext-Regular", size: 10)!)
    private let footerFont = Font(NSFont(name: "AvenirNext-UltraLight", size: 13)!)

    var body: some View {
        VStack(spacing: 0) {
            // Settings gear button at top right
            HStack {
                Spacer()
                settingsMenu
            }
            .padding(.top, 8)
            .padding(.trailing, 8)

            // Header with app icon and title
            VStack(spacing: 4) {
                Image(nsImage: NSImage(named: NSImage.applicationIconName)!)
                    .resizable()
                    .frame(width: 48, height: 48)

                Text("mizu")
                    .font(titleFont)
            }

            Spacer().frame(height: 20)

            // Interval section - label on left, slider on right
            HStack(alignment: .top, spacing: 12) {
                Text("Notify me every:")
                    .font(bodyFont)
                    .fixedSize()

                VStack(alignment: .leading, spacing: 2) {
                    Slider(
                        value: Binding(
                            get: { Double(settings.intervalRawValue) },
                            set: {
                                settings.intervalRawValue = Int($0)
                                onIntervalChanged?()
                            }
                        ),
                        in: 0...4,
                        step: 1
                    )
                    .controlSize(.small)

                    HStack {
                        Text("30 mins")
                        Spacer()
                        Text("1 hour")
                        Spacer()
                        Text("2 hours")
                    }
                    .font(captionFont)
                    .foregroundColor(.secondary)
                }
                .frame(width: 156)
            }
            .padding(.horizontal, 63)

            Divider()
                .frame(width: 224)
                .padding(.vertical, 20)

            // Play Sound toggle
            HStack(spacing: 12) {
                Toggle("", isOn: $settings.isSoundEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .controlSize(.small)

                Text("Play Sound")
                    .font(bodyFont)
                    .fixedSize()

                Spacer()
            }
            .padding(.horizontal, 63)

            Divider()
                .frame(width: 224)
                .padding(.vertical, 20)

            // Launch on startup toggle
            HStack(spacing: 12) {
                Toggle("", isOn: $settings.isLaunchAtLoginEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .controlSize(.small)

                Text("Launch on startup")
                    .font(bodyFont)
                    .fixedSize()

                Spacer()
            }
            .padding(.horizontal, 63)

            Divider()
                .frame(width: 224)
                .padding(.vertical, 20)

            Spacer()

            // Footer
            Text("Made with ❤️ in Berlin")
                .font(footerFont)
                .padding(.bottom, 13)
        }
        .frame(width: 350, height: 400)
    }

    private var settingsMenu: some View {
        Menu {
            Button("Notification Settings") {
                openNotificationSettings()
            }
            Divider()
            Button("@ES0XJEM") {
                openURL("https://www.twitter.com/ES0XJEM")
            }
            Button("GitHub") {
                openURL("https://www.github.com/esoxjem/Mizu")
            }
            Divider()
            Button("Quit Mizu") {
                NSApp.terminate(nil)
            }
        } label: {
            Image(systemName: "gear")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(width: 24, height: 24)
    }

    private func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview {
    PreferencesView(settings: AppSettings.shared)
}
