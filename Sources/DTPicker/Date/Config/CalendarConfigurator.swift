import UIKit

public struct CalendarConfigurator {
    
    public var tintColor: UIColor
    
    public var calendar: Calendar
    
    public var locale: Locale
    
    public var monthFont: UIFont
    
    public var weekdaysFont: UIFont
    
    public var dateFont: UIFont
    
    public var date: Date
    
    public var minimumDate: Date
    
    public var maximumDate: Date
    
    public init(
        tintColor: UIColor = .systemBlue,
        calendar: Calendar = Calendar.current,
        locale: Locale = Locale.current,
        monthFont: UIFont = .systemFont(ofSize: 17, weight: .semibold),
        weekdaysFont: UIFont = .systemFont(ofSize: 13, weight: .semibold),
        dateFont: UIFont = .systemFont(ofSize: 20, weight: .regular), date: Date = Date(),
        // 1 January 1970
        minimumDate: Date = Date(timeIntervalSince1970: 0),
        // 31 December 2099
        maximumDate: Date = Date(timeIntervalSince1970: 4102444799)
    ) {
        self.tintColor = tintColor
        self.calendar = calendar
        self.locale = locale
        self.monthFont = monthFont
        self.weekdaysFont = weekdaysFont
        self.dateFont = dateFont
        self.date = date
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
    }
    
}


