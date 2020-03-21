
protocol PreferencesView: class {
	func setInterval(interval: Int)
	func enableSoundSwitch()
	func disbleSoundSwitch()
	func enableStartupSwitch()
	func disbleStartupSwitch()
	func close()
}
