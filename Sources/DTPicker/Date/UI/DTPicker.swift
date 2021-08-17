import UIKit

public protocol DatePickerDelegate: AnyObject {
    func dateDidChanged(to newDate: Date)
}

protocol __DatePickerDelegate: AnyObject {
    func dateDidChanged(to newDate: Date)
}

protocol DatePickerConfig {
    var monthNameFont: UIFont { set get }
}

protocol DatePickerProtocol: UIView {
    var headerView: CalendarHeader { get }
    var weekdaysView: Weekdays { get }
    var calendarView: DPCalendar { get }
    var configurator: CalendarConfigurator { get }
    var monthYearSelectorView: CalendarMonthYearSelector { get }
    var delegate: DatePickerDelegate? { set get }
    
    func updateConfigurator(_ newConfigurator: CalendarConfigurator)
}

protocol MonthChangeMediator: AnyObject {
    func requestMonthChangeAnimation(to month: CDate)
    func didChangeMonth(_ newMonth: CDate)
}

public class DTPicker: UIView, DatePickerProtocol {
    
    private(set) public var configurator: CalendarConfigurator
    
    var headerView: CalendarHeader
    
    var weekdaysView: Weekdays
    
    var calendarView: DPCalendar
    
    var monthYearSelectorView: CalendarMonthYearSelector
    
    public weak var delegate: DatePickerDelegate?
    
    public override var intrinsicContentSize: CGSize {
        return .init(width: 300, height: 300)
    }
    
    public init(configurator: CalendarConfigurator = .init()) {
        self.configurator = configurator
        
        headerView = CalendarHeaderView()
        weekdaysView = WeekDaysView()
        calendarView = CalendarView()
        monthYearSelectorView = CalendarMonthYearSelectorView()
        
        super.init(frame: .zero)
        
        commonInit()
        updateConfigurator(configurator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateConfigurator(_ newConfigurator: CalendarConfigurator) {
        var config = newConfigurator
        config.calendar.locale = config.locale
        
        configurator = config
        
        let calendarData: CalendarData = getCalendarData()
        calendarView.setCalendarData(calendarData)
        monthYearSelectorView.setCalendarData(calendarData)
        headerView.setCalendarData(calendarData)
        
        let headerConfig = Config(color: config.tintColor, font: config.monthFont, calendar: config.calendar)
        headerView.updateConfig(new: headerConfig)
        
        let weekdaysConfig = Config(color: config.tintColor, font: config.weekdaysFont, calendar: config.calendar)
        weekdaysView.updateConfig(new: weekdaysConfig)
        
        let calendarConfig = Config(color: config.tintColor, font: .systemFont(ofSize: 20), calendar: config.calendar, showCurrentDay: config.showCurrentDay)
        calendarView.updateConfig(new: calendarConfig)
        
        let monthYearPickerConfig = Config(color: config.tintColor, font: .systemFont(ofSize: 22), calendar: config.calendar)
        monthYearSelectorView.updateConfig(new: monthYearPickerConfig)
    }
    
    private func commonInit() {
        addSubview(headerView)
        headerView.stickToSuperviewEdges([.left, .top, .right], insets: .init(top: 8, left: 0, bottom: 0, right: 0))
        
        addSubview(weekdaysView)
        weekdaysView.stickToSuperviewEdges([.left, .right])
        weekdaysView.top(14, to: headerView)
        weekdaysView.height(16)
        
        addSubview(calendarView)
        calendarView.stickToSuperviewEdges([.left, .right, .bottom], insets: .init(top: 0, left: 0, bottom: 12, right: 0))
        calendarView.top(to: weekdaysView)
        
        addSubview(monthYearSelectorView)
        monthYearSelectorView.stickToSuperviewEdges([.left, .right, .bottom], insets: .init(top: 0, left: 0, bottom: 12, right: 0))
        monthYearSelectorView.top(14, to: headerView)
        
        hideMonthYearPicker()
        
        
        headerView.mediator = self
        headerView.monthYearPickerDelegate = self
        calendarView.mediator = self
        calendarView.datePickerDelegate = self
        monthYearSelectorView.mediator = self
    }
    
    private func getCalendarData() -> CalendarData {
        let calendar = configurator.calendar
        let minDate = configurator.minimumDate.cdate(calendar: calendar)
        let maxDate = configurator.maximumDate.cdate(calendar: calendar)
        var selectedDate = configurator.date?.cdate(calendar: calendar)
        if let date = selectedDate {
            selectedDate = max(min(date, maxDate), minDate)
        }
        return CalendarData(minDate: minDate, maxDate: maxDate, selectedDate: selectedDate)
    }
    
}

extension DTPicker: MonthChangeMediator {
    
    func requestMonthChangeAnimation(to month: CDate) {
        calendarView.scrollToMonth(month, animated: true)
    }
    
    func didChangeMonth(_ newMonth: CDate) {
        var calendarData: CalendarData = getCalendarData()
        calendarData.selectedDate = newMonth
        headerView.setCalendarData(calendarData)
        if monthYearSelectorView.isHidden {
            monthYearSelectorView.scrollToMonth(newMonth, animated: false)
        }
    }
    
}

extension DTPicker: ShowMonthYearPickerDelegate {
    
    private enum MonthYearPickerState {
        case visible, hidden
    }
    
    private func changeMonthYearPickerState(for state: MonthYearPickerState) {
        if state == .visible {
            monthYearSelectorView.scrollToMonth(nil, animated: false)
        }
        
        let isHidden = state == .hidden
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) {
            
            self.monthYearSelectorView.isHidden = isHidden
            self.weekdaysView.isHidden = !isHidden
            self.calendarView.isHidden = !isHidden
            self.headerView.changeMonthButtons.isHidden = !isHidden
        }
    }
    
    func showMonthYearPicker() {
        changeMonthYearPickerState(for: .visible)
    }
    
    func hideMonthYearPicker() {
        changeMonthYearPickerState(for: .hidden)
    }
    
}

extension DTPicker: __DatePickerDelegate {
    
    func dateDidChanged(to newDate: Date) {
        configurator.date = newDate
        let calendarData: CalendarData = getCalendarData()
        calendarView.setCalendarData(calendarData)
        delegate?.dateDidChanged(to: newDate)
    }
    
}
