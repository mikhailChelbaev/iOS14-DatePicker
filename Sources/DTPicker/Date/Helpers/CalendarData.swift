import Foundation

struct CalendarData {
    
    var minDate: CDate
    
    var maxDate: CDate
    
    var selectedDate: CDate
    
    static let `default`: CalendarData = .init(
        minDate: .today,
        maxDate: .today,
        selectedDate: .today
    )
    
}
