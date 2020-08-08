//
//  CustomDatePicker.swift
//  DPicker
//
//  Created by Mikhail on 23.07.2020.
//

import UIKit

protocol CustomDatePickerDelegate: class {
    var tintColor: UIColor! { get }
    var bounds: CGRect { set get }
    
    var calendar: Calendar { get }
    var date: Date { set get }
    var minimumDate: DateComponents { get }
    var maximumDate: DateComponents { get }
    var currentComponents: DateComponents { set get }
    
    var selectedCellIndex: (page: Int, item: Int) { set get }
    var numberOfCells: Int { get }
}

public class CustomDatePicker: UIView, CustomDatePickerDelegate {
    
    // MARK: - CustomDatePickerDelegate properties
    
    var selectedCellIndex: (page: Int, item: Int) {
        didSet {
            // remove old mark
            if oldValue.page != selectedCellIndex.page, shouldUpdateCalendarPage {
                calendarView.reloadItems(at: [IndexPath(item: oldValue.page, section: 0)])
            }
            shouldUpdateCalendarPage = true
        }
    }
    
    var minimumDate: DateComponents
    
    var maximumDate: DateComponents
    
    var numberOfCells: Int
    
    var currentComponents: DateComponents {
        didSet {
            setMonthAndYear()
        }
    }
    
    var calendar: Calendar
    
    // MARK: - public properties
    
    public internal(set) var date: Date
    
    public var locale: Locale = Locale.autoupdatingCurrent {
        didSet {
            calendar.locale = locale
        }
    }
    
    // MARK: - private properties
    
    private var isMonthPickerHidden = true
    
    private var shouldUpdateCalendarPage = true
    
    // MARK: - ui elements
    
    private var monthAndYear: ExpandedButton = {
        let button = ExpandedButton()
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.customLabel, for: .normal)
        button.addTarget(self, action: #selector(showAndHideMonthPicker), for: .touchUpInside)
        return button
    }()
    
    private let calendarView = CalendarView()
    
    private let weekdaysView = WeekdaysView()
    
    private var monthPicker = MonthPickerView()
    
    private lazy var monthSelector: ExpandedButton = {
        let button = ExpandedButton()
        button.setBackgroundImage(UIImage(named: "chevron_forward", in: Bundle(for: CalendarView.self), compatibleWith: nil)!, for: .normal)
        button.addTarget(self, action: #selector(showAndHideMonthPicker), for: .touchUpInside)
        button.tintColor = tintColor
        return button
    }()
    
    private lazy var nextMonth: ExpandedButton = {
        let button = ExpandedButton()
        button.setBackgroundImage(UIImage(named: "chevron_forward", in: Bundle(for: CalendarView.self), compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(showMonth), for: .touchUpInside)
        button.tintColor = tintColor
        button.accessibilityLabel = "next month"
        return button
    }()
    
    private lazy var previousMonth: ExpandedButton = {
        let button = ExpandedButton()
        button.setBackgroundImage(UIImage(named: "chevron_backward", in: Bundle(for: CalendarView.self), compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(showMonth), for: .touchUpInside)
        button.tintColor = tintColor
        button.accessibilityLabel = "previous month"
        return button
    }()
    
    // MARK: - override fields
    
    public override var intrinsicContentSize: CGSize {
        let monthViewSize = CGSize.calculateMonthViewSize()
        return .init(width: monthViewSize.width, height: monthViewSize.height + .weekdayCellHeight + .monthButtonHeight)
    }
    
    // MARK: - init
    
    override init(frame: CGRect) {
        date = Date()
        calendar = Calendar.current
        currentComponents = calendar.dateComponents([.month, .year], from: date)
        minimumDate = DateComponents(year: 1900, month: 1)
        maximumDate = DateComponents(year: 2100, month: 12)
        numberOfCells = (maximumDate.year! - minimumDate.year! + 1) * 12
        
        // calculation selected cell index
        let components = calendar.dateComponents([.month, .year], from: date)
        let page = (components.year! - minimumDate.year!) * 12 + components.month!
        let firstDay = calendar.date(from: components)
        let weekday = calendar.component(.weekday, from: firstDay!)
        let item = weekday + calendar.component(.day, from: date) - 2
        selectedCellIndex = (page, item)
        
        super.init(frame: frame)
        
        tintColor = .systemBlue
        monthPicker.alpha = 0
        
        setDelegates()
        setMonthAndYear()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public methods
    
    public func setDate(_ date: Date) {
        self.date = date
        shouldUpdateCalendarPage = false
        currentComponents = calendar.dateComponents([.month, .year], from: date)
        calculateCellIndex()
        calendarView.scrollToCurrentMonth(animated: true)
    }
    
    // MARK: - internal methods
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        anchorItems()
    }
    
    // MARK: - private methods
    
    private func anchorItems() {
        addSubview(monthAndYear)
        monthAndYear.anchor(top: topAnchor, leading: leadingAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        
        addSubview(monthSelector)
        monthSelector.anchor(leading: monthAndYear.trailingAnchor, padding: .init(top: 0, left: 3, bottom: 0, right: 0), size: .init(width: 10, height: 18))
        monthSelector.centerYAnchor.constraint(equalTo: monthAndYear.centerYAnchor).isActive = true
        
        addSubview(nextMonth)
        nextMonth.anchor(top: topAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 10), size: .init(width: 14, height: 23))
        
        addSubview(previousMonth)
        previousMonth.anchor(top: topAnchor, trailing: nextMonth.leadingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 29), size: .init(width: 14, height: 23))
        
        addSubview(weekdaysView)
        weekdaysView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: .init(top: .monthButtonHeight, left: 0, bottom: 0, right: 0), size: .init(width: bounds.size.width, height: .weekdayCellHeight))
        
        addSubview(calendarView)
        calendarView.anchor(top: weekdaysView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, size: .calculateMonthViewSize(bounds: bounds))        
        
        addSubview(monthPicker)
        monthPicker.anchor(top: weekdaysView.topAnchor, leading: leadingAnchor, bottom: calendarView.bottomAnchor, trailing: trailingAnchor)
    }
    
    private func setDelegates() {
        monthPicker.datePickerDelegate = self
        weekdaysView.datePickerDelegate = self
        calendarView.datePickerDelegate = self        
    }
    
    private func setMonthAndYear() {
        let text = "\(calendar.monthSymbols[currentComponents.month! - 1]) \(currentComponents.year!)"
        monthAndYear.setTitle(text, for: .normal)
    }
    
    private func calculateCellIndex() {
        let components = calendar.dateComponents([.month, .year], from: date)
        selectedCellIndex.page = (components.year! - minimumDate.year!) * 12 + components.month!
        let firstDay = calendar.date(from: components)
        let weekday = calendar.component(.weekday, from: firstDay!)
        selectedCellIndex.item = weekday + calendar.component(.day, from: date) - 2
    }
    
    // MARK: - button handlers
    
    @objc private func showMonth(_ sender: UIButton) {
        let value = sender.accessibilityLabel == "next month" ? 1 : -1
        let date = calendar.date(from: currentComponents)!
        let nextMonth = calendar.date(byAdding: .month, value: value, to: date)
        let components = calendar.dateComponents([.month, .year], from: nextMonth!)
        calendarView.scrollToMonth(components, animated: true)
    }
    
    @objc private func showPreviousMonth() {
        if let ip = calendarView.indexPath(for: calendarView.visibleCells[0]) {
            calendarView.scrollToItem(at: IndexPath(item: ip.item - 1, section: ip.section), at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc private func showAndHideMonthPicker() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
            let backgroundViews = [
                self.nextMonth,
                self.calendarView,
                self.weekdaysView,
                self.previousMonth
            ]
            if self.isMonthPickerHidden {
                self.monthSelector.transform = CGAffineTransform(rotationAngle: .pi / 2)
                self.monthAndYear.setTitleColor(self.tintColor, for: .normal)
                self.monthPicker.selectRows()
                self.monthPicker.alpha = 1
                backgroundViews.forEach({ $0.alpha = 0 })
            } else {
                self.monthSelector.transform = .identity
                self.monthAndYear.setTitleColor(.customLabel, for: .normal)
                self.calendarView.scrollToCurrentMonth()
                self.monthPicker.alpha = 0
                backgroundViews.forEach({ $0.alpha = 1 })
            }
            self.isMonthPickerHidden.toggle()
        })

    }
    
}
