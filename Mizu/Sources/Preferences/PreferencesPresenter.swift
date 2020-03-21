import Cocoa

final class PreferencesPresenter {
	
	private weak var view: PreferencesView?
	private let preferences: Preferences
	
	init(preferences: Preferences = Preferences()) {
		self.preferences = preferences
	}
	
	func viewDidLoad(view: PreferencesView) {
		self.view = view
		
		restoreUserPreferences()
	}
	
	private func restoreUserPreferences() {
		if preferences.isSoundEnabled() {
			view?.enableSoundSwitch()
		} else {
			view?.disbleSoundSwitch()
		}
		
		if preferences.isStartupLaunch() {
			view?.enableStartupSwitch()
		} else {
			view?.disbleStartupSwitch()
		}
		
		view?.setInterval(interval: preferences.selectedInterval())
	}
	
	func sliderMoved(value: Int) {
		preferences.saveSelectedInterval(value)
		(NSApp.delegate as? AppDelegate)?.resetTimer()
	}
	
	func soundSwitchToggled(state: NSSwitch.StateValue) {
		var isEnabled = true
		if state == .off {
			isEnabled = false
		}
		preferences.saveSound(isEnabled: isEnabled)
	}
	
	func startupSwitchToggled(state: NSSwitch.StateValue) {
		var isEnabled = true
		if state == .off {
			isEnabled = false
		}
		preferences.saveStartupLaunch(isEnabled: isEnabled)
	}
	
}
