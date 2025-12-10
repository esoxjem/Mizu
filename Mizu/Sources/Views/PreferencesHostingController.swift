import AppKit
import SwiftUI

/// NSHostingController wrapper for PreferencesView to use with NSPopover.
/// Bridges SwiftUI into the AppKit popover system.
final class PreferencesHostingController: NSHostingController<PreferencesView> {

    /// Creates a hosting controller with the given settings and callback.
    /// - Parameters:
    ///   - settings: The AppSettings instance to bind to the view
    ///   - onIntervalChanged: Callback when the interval slider changes
    convenience init(settings: AppSettings, onIntervalChanged: @escaping () -> Void) {
        let view = PreferencesView(settings: settings, onIntervalChanged: onIntervalChanged)
        self.init(rootView: view)
    }

    @MainActor
    required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor
    required override init(rootView: PreferencesView) {
        super.init(rootView: rootView)
    }
}
