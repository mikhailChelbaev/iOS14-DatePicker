import UIKit

protocol Configurable {
    var config: DTConfig? { get }
    
    func updateConfig(new config: DTConfig)
}

typealias ConfigurableView = UIView & Configurable

protocol DTConfig {
    var color: UIColor { get }
    var font: UIFont { get }
    var calendar: Calendar { get }
    var showCurrentDay: Bool { get }
}

struct Config: DTConfig {
    var color: UIColor
    var font: UIFont
    var calendar: Calendar
    var showCurrentDay: Bool = true
}
