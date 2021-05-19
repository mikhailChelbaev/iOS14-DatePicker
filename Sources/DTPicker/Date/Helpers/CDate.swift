import Foundation

struct CDate: Equatable {
    
    private(set) var day: Int
    
    private(set) var month: Int
    
    private(set) var year: Int
    
    private(set) var numberOfDays: Int
    
    private(set) var numberOfWeeks: Int
    
    private(set) var firstWeekdayInMonth: Int
    
    private let calendar: Calendar
    
    private var date: Date
    
    static let today: CDate = .init(from: Date(), calendar: Calendar.current)
    
    init(from date: Date, calendar: Calendar) {
        self.calendar = calendar
        self.date = date
        self.day = calendar.component(.day, from: date)
        self.month = calendar.component(.month, from: date)
        self.year = calendar.component(.year, from: date)
        self.numberOfDays = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        self.firstWeekdayInMonth = 0
        self.numberOfWeeks = calendar.range(of: .weekOfMonth, in: .month, for: date)?.count ?? 0
        
        firstWeekdayInMonth = (calendar.component(.weekday, from: beginOfMonth().date) - calendar.firstWeekday + 7) % 7
    }
    
    func numberOfMonths(to date: CDate) -> Int {
        if self > date {
            return 0
        }
        
        return date.year * 12 + date.month - (self.year * 12 + self.month) + 1
    }
    
    func addingMonths(_ value: Int) -> CDate {
        let components = DateComponents(year: value / 12, month: value % 12, day: 0)
        let newDate = calendar.date(byAdding: components, to: date) ?? date
        return CDate(from: newDate, calendar: calendar)
    }
    
    mutating func increaseDays() {
        day = min(numberOfDays, day + 1)
        if day <= numberOfDays {
            date.addTimeInterval(24 * 60 * 60)
        }
    }
    
    func beginOfMonth() -> CDate {
        var copy = self
        copy.day = 1
        copy.date.addTimeInterval(-24 * 60 * 60 * TimeInterval(day - 1))
        return copy
    }
    
}

extension CDate {
    
    func toDate() -> Date {
        return date
    }
    
}

extension CDate: Comparable {
    
    static func == (lhs: CDate, rhs: CDate) -> Bool {
        return lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year
    }

    static func > (lhs: CDate, rhs: CDate) -> Bool {
        if lhs.year > rhs.year {
            return true
        } else if lhs.year == rhs.year && lhs.month > rhs.month {
            return true
        } else if lhs.year == rhs.year && lhs.month == rhs.month && lhs.day > rhs.day {
            return true
        }
        return false
    }
    
    static func < (lhs: CDate, rhs: CDate) -> Bool {
        if lhs.year < rhs.year {
            return true
        } else if lhs.year == rhs.year && lhs.month < rhs.month {
            return true
        } else if lhs.year == rhs.year && lhs.month == rhs.month && lhs.day < rhs.day {
            return true
        }
        return false
    }
    
}

extension Date {
    
    func cdate(calendar: Calendar = Calendar.current) -> CDate {
        return CDate(from: self, calendar: calendar)
    }
    
}
