import UIKit

protocol CalendarMonthYearSelector: ConfigurableView {
    var mediator: MonthChangeMediator? { set get }
    
    func setCalendarData(_ data: CalendarData)
    func scrollToMonth(_ date: CDate?, animated: Bool)
}

class CalendarMonthYearSelectorView: UIView, CalendarMonthYearSelector {
    
    var config: DTConfig?
    
    weak var mediator: MonthChangeMediator?
    
    private var data: CalendarData
    
    private var numberOfYears: Int = 0
    
    private var selectedRows: [Int] = [0, 0]
    
    private let datePicker = UIPickerView()
    
    init() {
        data = .default
        
        super.init(frame: .zero)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(datePicker)
        datePicker.stickToSuperviewEdges(.all)
        
        datePicker.dataSource = self
        datePicker.delegate = self
        
        datePicker.reloadAllComponents()
    }
    
    func setCalendarData(_ data: CalendarData) {
        self.data = data
        
        numberOfYears = data.maxDate.year - data.minDate.year + 1
        
        datePicker.reloadAllComponents()
    }
    
    func scrollToMonth(_ date: CDate?, animated: Bool) {
        var month: Int = selectedRows[0]
        var year: Int = selectedRows[1]
        if let date = date {
            month = date.month - 1
            year = date.year - data.minDate.year
        }
        
        datePicker.selectRow(month, inComponent: 0, animated: animated)
        datePicker.selectRow(year, inComponent: 1, animated: animated)
        
        selectedRows = [month, year]
    }
    
    func updateConfig(new config: DTConfig) {
        self.config = config
    }
    
    private func dateForComponents(_ components: [Int]? = nil) -> CDate {
        let rows: [Int] = components ?? selectedRows
        let numberOfMonths = rows[1] * 12 + (rows[0] + 1) - data.minDate.month
        let date = data.minDate.addingMonths(numberOfMonths)
        return date
    }
    
}

extension CalendarMonthYearSelectorView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return [12, numberOfYears][component]
    }
    
}

extension CalendarMonthYearSelectorView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0 {
            let text: String = config?.calendar.standaloneMonthSymbols[row] ?? ""
            let components: [Int] = [row, selectedRows[1]]
            let date: CDate = dateForComponents(components).beginOfMonth()

            if date < data.minDate.beginOfMonth() || date > data.maxDate.beginOfMonth() {
                return NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.secondaryLabel])
            }

            return NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.label])
        } else {
            let text: String = "\(data.minDate.year + row)"
            return NSAttributedString(string: text)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRows[component] = row
        let selectedDate: CDate = dateForComponents().beginOfMonth()
        if selectedDate >= data.minDate.beginOfMonth() && selectedDate <= data.maxDate.beginOfMonth() {
            mediator?.requestMonthChangeAnimation(to: dateForComponents())
        } else if selectedDate < data.minDate.beginOfMonth() {
            scrollToMonth(data.minDate, animated: true)
            mediator?.requestMonthChangeAnimation(to: data.minDate)
        } else {
            scrollToMonth(data.maxDate, animated: true)
            mediator?.requestMonthChangeAnimation(to: data.maxDate)
        }
        
        if component == 1 {
            datePicker.reloadComponent(0)
        }
    }
    
}
