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
        var time = ""
        
        switch preferences.selectedInterval() {
        case 0:
            time = "30 mins"
        case 1:
            time = "45 mins"
        case 2:
            time = "1 hour"
        case 3:
            time = "1.5 hours"
        case 4:
            time = "2 hours"
        default:
            break
        }
        
        return time
    }
}
