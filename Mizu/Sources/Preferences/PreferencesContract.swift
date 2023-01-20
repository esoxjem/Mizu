
protocol PreferencesView: AnyObject {
    func setInterval(interval: Int)
    func enableSoundSwitch()
    func disbleSoundSwitch()
    func enableStartupSwitch()
    func disbleStartupSwitch()
    func close()
}
