import AppKit
import SwiftUI

/// NSHostingController wrapper for PreferencesView to use with NSPopover.
/// Bridges SwiftUI into the AppKit popover system.
final class PreferencesHostingController: NSHostingController<PreferencesView> {

    convenience init(settings: AppSettings) {
        let view = PreferencesView(settings: settings)
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
