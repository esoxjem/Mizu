import Foundation

class Interval {
	
	let preferences = Preferences()
	
	func seconds() -> Double {
		var mins = 0
		switch preferences.selectedInterval() {
		case 0:
			mins = 30
		case 1:
			mins = 45
		case 2:
			mins = 60
		case 3:
			mins = 90
		case 4:
			mins = 120
		default:
			break
		}
		
		return Double(mins * 60)
	}
	
	func string() -> String {
		var lastCup = ""
		
		switch preferences.selectedInterval() {
		case 0:
			lastCup = "30 mins"
		case 1:
			lastCup = "45 mins"
		case 2:
			lastCup = "1 hour"
		case 3:
			lastCup = "1.5 hours"
		case 4:
			lastCup = "2 hours"
		default:
			break
		}
		
		return lastCup
	}
}
