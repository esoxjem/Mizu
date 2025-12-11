import SwiftUI
import AppKit

struct PreferencesView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject private var updaterService = UpdaterService.shared
    var onIntervalChanged: (() -> Void)?

    private let actions = PreferencesActions.shared

    var body: some View {
        VStack(spacing: 0) {
            appHeader
            Spacer().frame(height: 20)
            intervalSelector
            sectionDivider
            settingToggle(label: "Play Sound", isOn: $settings.isSoundEnabled)
            sectionDivider
            settingToggle(label: "Launch on startup", isOn: $settings.isLaunchAtLoginEnabled)
            Spacer()
            footerText
        }
        .frame(width: 350, height: 400)
        .overlay(alignment: .topTrailing) {
            settingsMenu
                .padding(.top, 12)
                .padding(.trailing, 12)
        }
    }

    private var appHeader: some View {
        VStack(spacing: 4) {
            Image(nsImage: NSImage(named: NSImage.applicationIconName)!)
                .resizable()
                .frame(width: 48, height: 48)

            Text("mizu")
                .font(Typography.title)
        }
        .padding(.top, 24)
    }

    private var intervalSelector: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("Notify me every:")
                .font(Typography.body)
                .fixedSize()

            VStack(alignment: .leading, spacing: 2) {
                Slider(value: intervalBinding, in: 0...4, step: 1)
                    .controlSize(.small)

                intervalLabels
            }
            .frame(width: 156)
        }
        .padding(.horizontal, 63)
    }

    private var intervalBinding: Binding<Double> {
        Binding(
            get: { Double(settings.intervalRawValue) },
            set: { newValue in
                settings.intervalRawValue = Int(newValue)
                onIntervalChanged?()
            }
        )
    }

    private var intervalLabels: some View {
        HStack {
            Text("30 mins")
            Spacer()
            Text("1 hour")
            Spacer()
            Text("2 hours")
        }
        .font(Typography.caption)
        .foregroundColor(.secondary)
    }

    private func settingToggle(label: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.small)

            Text(label)
                .font(Typography.body)
                .fixedSize()

            Spacer()
        }
        .padding(.horizontal, 63)
    }

    private var sectionDivider: some View {
        Divider()
            .frame(width: 224)
            .padding(.vertical, 20)
    }

    private var footerText: some View {
        Text("Made with ❤️ in Berlin")
            .font(Typography.footer)
            .padding(.bottom, 32)
    }

    private var settingsMenu: some View {
        Menu {
            if updaterService.updateAvailabilityState.isUpdateAvailable {
                updateAvailableButton
                Divider()
            }
            Button("Check for Updates", action: actions.checkForUpdates)
                .disabled(!updaterService.canCheckForUpdates)
            Divider()
            Button("Notification Settings", action: actions.openNotificationSettings)
            Divider()
            Button("@ES0XJEM", action: actions.openTwitter)
            Button("GitHub", action: actions.openGitHub)
            Divider()
            Button("Quit Mizu", action: actions.quitApplication)
        } label: {
            settingsMenuIcon
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }

    private var updateAvailableButton: some View {
        Button(action: updaterService.installPendingUpdate) {
            Label(updateButtonTitle, systemImage: "arrow.down.circle.fill")
        }
    }

    private var updateButtonTitle: String {
        if let version = updaterService.updateAvailabilityState.availableVersion {
            return "Install Update (\(version))"
        }
        return "Install Update"
    }

    private var settingsMenuIcon: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "gearshape")
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            if updaterService.updateAvailabilityState.isUpdateAvailable {
                Circle()
                    .fill(Color.red)
                    .frame(width: 6, height: 6)
                    .offset(x: 2, y: -2)
            }
        }
    }
}

private enum Typography {
    static let title = avenirFont(weight: "UltraLight", size: 24)
    static let body = avenirFont(weight: "Medium", size: 13)
    static let caption = avenirFont(weight: "Regular", size: 10)
    static let footer = avenirFont(weight: "UltraLight", size: 13)

    private static func avenirFont(weight: String, size: CGFloat) -> Font {
        Font(NSFont(name: "AvenirNext-\(weight)", size: size)!)
    }
}

#Preview {
    PreferencesView(settings: AppSettings.shared)
}
