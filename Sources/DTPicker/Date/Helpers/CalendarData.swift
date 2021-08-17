import Foundation

struct CalendarData {
    
    var minDate: CDate
    
    var maxDate: CDate
    
    var selectedDate: CDate?
    
    var selectedDateOrToday: CDate {
        selectedDate ?? .today
    }
    
    static let `default`: CalendarData = .init(
        minDate: .today,
        maxDate: .today,
        selectedDate: .today
    )
    
}
