import UIKit

public struct CalendarConfigurator {
    
    public var tintColor: UIColor
    
    public var calendar: Calendar
    
    public var locale: Locale
    
    public var monthFont: UIFont
    
    public var weekdaysFont: UIFont
    
    public var date: Date?
    
    public var minimumDate: Date
    
    public var maximumDate: Date
    
    public var showCurrentDay: Bool
    
    public init(
        tintColor: UIColor = .systemBlue,
        calendar: Calendar = Calendar.current,
        locale: Locale = Locale.current,
        monthFont: UIFont = .systemFont(ofSize: 17, weight: .semibold),
        weekdaysFont: UIFont = .systemFont(ofSize: 13, weight: .semibold),
        date: Date? = Date(),
        minimumDate: Date = .distantPast,
        maximumDate: Date = .distantFuture,
        showCurrentDay: Bool = true
    ) {
        self.tintColor = tintColor
        self.calendar = calendar
        self.locale = locale
        self.monthFont = monthFont
        self.weekdaysFont = weekdaysFont
        self.date = date
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.showCurrentDay = showCurrentDay
    }
    
}


