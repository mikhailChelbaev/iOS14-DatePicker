import UIKit

protocol CalendarHeader: ConfigurableView {
    var mediator: MonthChangeMediator? { set get }
    var monthYearPickerDelegate: ShowMonthYearPickerDelegate? { set get }
    var showYearPickerView: ShowYearPicker { get }
    var changeMonthButtons: ChangeMonthButtons { get }
    
    func setCalendarData(_ data: CalendarData)
}

class CalendarHeaderView: UIView, CalendarHeader {
    
    var config: DTConfig?
    
    private var data: CalendarData
    
    weak var mediator: MonthChangeMediator?
    
    weak var monthYearPickerDelegate: ShowMonthYearPickerDelegate?
    
    let showYearPickerView: ShowYearPicker
    
    let changeMonthButtons: ChangeMonthButtons
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
    
    init() {
        showYearPickerView = ShowYearPickerView()
        changeMonthButtons = ChangeMonthButtonsView()
        data = .default
        
        super.init(frame: .zero)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(showYearPickerView)
        showYearPickerView.leading(4)
        showYearPickerView.centerVertically()
        
        addSubview(changeMonthButtons)
        changeMonthButtons.trailing(8)
        changeMonthButtons.leadingAnchor.constraint(greaterThanOrEqualTo: showYearPickerView.trailingAnchor, constant: 8).isActive = true
        changeMonthButtons.centerVertically()
        
        height(23)
        
        changeMonthButtons.delegate = self
        showYearPickerView.delegate = self
    }
    
    func updateConfig(new config: DTConfig) {
        self.config = config
        showYearPickerView.updateConfig(new: config)
        changeMonthButtons.updateConfig(new: config)
        formatter.calendar = config.calendar
    }
    
    func setCalendarData(_ data: CalendarData) {
        self.data = data
        showYearPickerView.setTitleText(formatter.string(from: data.selectedDateOrToday.toDate()))
        changeMonthButtons.previousMonth.isEnabled = !isMonthsEqual(data.selectedDateOrToday, data.minDate)
        changeMonthButtons.nextMonth.isEnabled = !isMonthsEqual(data.selectedDateOrToday, data.maxDate)
    }
    
    func isMonthsEqual(_ left: CDate, _ right: CDate) -> Bool {
        return left.month == right.month && left.year == right.year
    }
    
}

extension CalendarHeaderView: ChangeMonthDelegate {
    
    func showPreviousMonth() {
        let month = data.selectedDateOrToday.addingMonths(-1)
        mediator?.requestMonthChangeAnimation(to: month)
    }
    
    func showNextMonth() {
        let month = data.selectedDateOrToday.addingMonths(1)
        mediator?.requestMonthChangeAnimation(to: month)
    }
    
}

extension CalendarHeaderView: ShowMonthYearPickerDelegate {
    
    func showMonthYearPicker() {
        monthYearPickerDelegate?.showMonthYearPicker()
    }
    
    func hideMonthYearPicker() {
        monthYearPickerDelegate?.hideMonthYearPicker()
    }
    
}
