import UIKit

class MonthPickerView: UIView {
    
    weak var datePickerDelegate: CustomDatePickerDelegate? {
        didSet {
            monthPicker.reloadAllComponents()
        }
    }
    
    let monthPicker = UIPickerView()
    
    private var selectedRows = [0, 0]
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        
        monthPicker.dataSource = self
        monthPicker.delegate = self
        anchorPicker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectRows() {
        guard let delegate = datePickerDelegate else { return }
        
        let year = delegate.currentComponents.year! - delegate.minimumDate.year!
        let month = delegate.currentComponents.month! - 1
        
        selectedRows = [month, year]
        monthPicker.selectRow(month, inComponent: 0, animated: false)
        monthPicker.selectRow(year, inComponent: 1, animated: false)
    }
    
    private func anchorPicker() {
        addSubview(monthPicker)
        monthPicker.anchorToCenter(parent: self)
    }
    
}

extension MonthPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12
        } else {
            if let delegate = datePickerDelegate {
                return delegate.maximumDate.year! - delegate.minimumDate.year! + 1
            } else {
                return 0
            }
        }
    }
}

extension MonthPickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return datePickerDelegate?.calendar.standaloneMonthSymbols[row] ?? ""
        } else {
            if let delegate = datePickerDelegate {
                return "\(delegate.minimumDate.year! + row)"
            } else {
                return "2020"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let minimumYear = datePickerDelegate?.minimumDate.year else { return }
        selectedRows[component] = row
        datePickerDelegate?.currentComponents = DateComponents(year: minimumYear + selectedRows[1], month: selectedRows[0] + 1)
    }

}
