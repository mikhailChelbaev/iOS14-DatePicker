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

public protocol DatePickerEvents: class {
    func dateDidChanged(oldDate: Date, newDate: Date)
}

public class CustomDatePicker: UIView, CustomDatePickerDelegate {
    
    // MARK: - DatePickerEvents
    
    public weak var delegate: DatePickerEvents?
    
    // MARK: - CustomDatePickerDelegate properties
    
    var selectedCellIndex: (page: Int, item: Int) {
        didSet {
            if oldValue != selectedCellIndex {
                updateCalendarPages(oldSelectedCellIndex: oldValue, newSelectedCellIndex: selectedCellIndex)
            }
        }
    }
    
    var minimumDate: DateComponents
    
    var maximumDate: DateComponents
    
    var numberOfCells: Int
    
    var currentComponents: DateComponents {
        didSet {
            setMonthAndYear()
            checkDate()
        }
    }
    
    var calendar: Calendar
    
    // MARK: - public properties
    
    public internal(set) var date: Date {
        didSet {
            delegate?.dateDidChanged(oldDate: oldValue, newDate: date)
        }
    }
    
    public var locale: Locale = Locale.autoupdatingCurrent {
        didSet {
            updateLocale()
        }
    }
    
    // MARK: - private properties
    
    private var minimumYear: Int
    
    private var maximumYear: Int
    
    // MARK: - ui elements
    
    private var monthAndYear: ExpandedButton = {
        let button = ExpandedButton()
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(showAndHideMonthPicker), for: .touchUpInside)
        return button
    }()
    
    private let calendarView = CalendarView()
    
    private let weekdaysView = WeekdaysView()
    
    private var monthPicker = MonthPickerView()
    
    private lazy var monthSelector: ExpandedButton = {
        let button = ExpandedButton()
        button.setBackgroundImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.addTarget(self, action: #selector(showAndHideMonthPicker), for: .touchUpInside)
        button.tintColor = tintColor
        return button
    }()
    
    private lazy var nextMonth: ExpandedButton = {
        let button = ExpandedButton()
        button.setBackgroundImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.addTarget(self, action: #selector(showMonth), for: .touchUpInside)
        button.tintColor = tintColor
        button.tag = 0
        return button
    }()
    
    private lazy var previousMonth: ExpandedButton = {
        let button = ExpandedButton()
        button.setBackgroundImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(showMonth), for: .touchUpInside)
        button.tintColor = tintColor
        button.tag = 1
        return button
    }()
    
    // MARK: - override fields
    
    public override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        let monthViewSize = CGSize.calculateMonthViewSize(bounds: bounds)
        return .init(width: monthViewSize.width, height: monthViewSize.height + .weekdayCellHeight + .monthButtonHeight + .bottomOffset)
    }
    
    // MARK: - init
    
    public init(date: Date = Date(),
                minimumYear: Int = 1900,
                maximumYear: Int = 2100,
                calendar: Calendar = Calendar.current,
                locale: Locale = Locale.autoupdatingCurrent) {
        self.date = date
        self.calendar = calendar
        
        self.minimumYear = minimumYear
        self.maximumYear = maximumYear
        if self.minimumYear > self.maximumYear {
            swap(&self.minimumYear, &self.maximumYear)
        }
        self.maximumYear = maximumYear > 2100 ? 2100 : maximumYear
        self.maximumYear = maximumYear < 1900 ? 1900 : maximumYear
        maximumDate = DateComponents(year: self.maximumYear, month: 12)
        self.minimumYear = minimumYear > 2100 ? 2100 : minimumYear
        self.minimumYear = minimumYear < 1900 ? 1900 : minimumYear
        minimumDate = DateComponents(year: self.minimumYear, month: 1)
        
        self.locale = locale
        self.calendar.locale = locale
        
        currentComponents = calendar.dateComponents([.month, .year], from: date)
        numberOfCells = (maximumDate.year! - minimumDate.year! + 1) * 12 + 1
        
        // calculation selected cell index
        let components = self.calendar.dateComponents([.month, .year], from: date)
        let page = (components.year! - self.minimumDate.year!) * 12 + components.month!
        let firstDay = self.calendar.date(from: components)
        var weekday = (self.calendar.component(.weekday, from: firstDay!) - self.calendar.firstWeekday + 1) % 7
        weekday = weekday == 0 ? 7 : weekday
        let item = weekday + self.calendar.component(.day, from: date) - 2
        selectedCellIndex = (page, item)
        
        super.init(frame: .init(x: 0, y: 0, width: 300, height: 300))
        
        tintColor = .systemBlue
        monthPicker.isHidden = true
        
        setDelegates()
        setMonthAndYear()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public methods
    
    public func setDate(_ date: Date) {
        self.date = date
        currentComponents = calendar.dateComponents([.month, .year], from: date)
        calculateCellIndex()
        calendarView.scrollToCurrentMonth(animated: true)
    }
    
    public func hideMonthAndYearPicker() {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            self.monthSelector.transform = .identity
            self.monthAndYear.setTitleColor(.label, for: .normal)
            self.calendarView.scrollToCurrentMonth()
            self.monthPicker.isHidden = true
            self.nextMonth.isHidden = false
            self.previousMonth.isHidden = false
            self.calendarView.isHidden = false
            self.weekdaysView.isHidden = false
        }
    }
    
    public func showMonthAndYearPicker() {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            self.monthSelector.transform = CGAffineTransform(rotationAngle: .pi / 2)
            self.monthAndYear.setTitleColor(self.tintColor, for: .normal)
            self.monthPicker.selectRows()
            self.monthPicker.isHidden = false
            self.nextMonth.isHidden = true
            self.previousMonth.isHidden = true
            self.calendarView.isHidden = true
            self.weekdaysView.isHidden = true
        }
    }
    
    public func scrollToDate(date: Date? = nil, animated: Bool = true) {
        let components = calendar.dateComponents([.month, .year], from: date ?? self.date)
        calendarView.scrollToMonth(components, animated: animated)
    }
    
    // MARK: - internal methods
    
    private var firstUpdate = true
    public override func layoutSubviews() {
        super.layoutSubviews()
        if firstUpdate {
            anchorItems()
        }
        firstUpdate = false
    }
    
    // MARK: - private methods
    
    private func anchorItems() {
        addSubview(monthAndYear)
        monthAndYear.anchor(top: topAnchor, leading: leadingAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        
        addSubview(monthSelector)
        monthSelector.anchor(leading: monthAndYear.trailingAnchor, padding: .init(top: 0, left: 3, bottom: 0, right: 0), size: .init(width: 10, height: 18))
        monthSelector.centerYAnchor.constraint(equalTo: monthAndYear.centerYAnchor).isActive = true
        
        addSubview(nextMonth)
        nextMonth.anchor(trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 10), size: .init(width: 14, height: 23))
        
        addSubview(previousMonth)
        previousMonth.anchor(trailing: nextMonth.leadingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 29), size: .init(width: 14, height: 23))
        [nextMonth, previousMonth].forEach( {$0.centerYAnchor.constraint(equalTo: monthAndYear.centerYAnchor).isActive = true })
        
        addSubview(weekdaysView)
        weekdaysView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: .init(top: .monthButtonHeight, left: 0, bottom: 0, right: 0), size: .init(width: bounds.size.width, height: .weekdayCellHeight))
        
        let monthViewSize: CGSize = .calculateMonthViewSize(bounds: bounds)
        addSubview(calendarView)
        calendarView.anchor(top: weekdaysView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, size: .init(width: monthViewSize.width, height: monthViewSize.height + .bottomOffset))
        
        addSubview(monthPicker)
        monthPicker.anchor(top: weekdaysView.topAnchor, leading: leadingAnchor, bottom: calendarView.bottomAnchor, trailing: trailingAnchor)
    }
    
    private func setDelegates() {
        monthPicker.datePickerDelegate = self
        weekdaysView.datePickerDelegate = self
        calendarView.datePickerDelegate = self
    }
    
    private func setMonthAndYear() {
        let text = "\(calendar.standaloneMonthSymbols[currentComponents.month! - 1]) \(currentComponents.year!)"
        monthAndYear.setTitle(text, for: .normal)
    }
    
    private func calculateCellIndex() {
        let components = calendar.dateComponents([.month, .year], from: date)
        let page = (components.year! - minimumDate.year!) * 12 + components.month!
        let firstDay = calendar.date(from: components)
        var weekday = (calendar.component(.weekday, from: firstDay!) - calendar.firstWeekday + 1) % 7
        weekday = weekday == 0 ? 7 : weekday
        let item = weekday + calendar.component(.day, from: date) - 2
        selectedCellIndex = (page: page, item: item)
    }
    
    private func checkDate() {
        previousMonth.isEnabled = currentComponents != minimumDate
        nextMonth.isEnabled = currentComponents != maximumDate
    }
    
    // MARK: - update
    
    private func updateCalendarPages(oldSelectedCellIndex: (page: Int, item: Int),
                                     newSelectedCellIndex: (page: Int, item: Int)) {
        NotificationCenter.default.post(name: .select, object: nil, userInfo: ["page": newSelectedCellIndex.page, "item": newSelectedCellIndex.item])
        NotificationCenter.default.post(name: .deselect, object: nil, userInfo: ["page": oldSelectedCellIndex.page, "item": oldSelectedCellIndex.item])
    }
    
    private func updateLocale() {
        calendar.locale = locale
        weekdaysView.reloadData()
        calendarView.reloadData()
        calculateCellIndex()
        setMonthAndYear()
    }
    
    // MARK: - button handlers
    
    @objc private func showMonth(_ sender: UIButton) {
        let value = sender.tag == 0 ? 1 : -1
        let date = calendar.date(from: currentComponents)!
        let nextMonth = calendar.date(byAdding: .month, value: value, to: date)
        currentComponents = calendar.dateComponents([.month, .year], from: nextMonth!)
        calendarView.scrollToCurrentMonth(animated: true)
    }
    
    @objc private func showAndHideMonthPicker() {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            if self.monthPicker.isHidden {
                self.monthSelector.transform = CGAffineTransform(rotationAngle: .pi / 2)
                self.monthAndYear.setTitleColor(self.tintColor, for: .normal)
                self.monthPicker.selectRows()
            } else {
                self.monthSelector.transform = .identity
                self.monthAndYear.setTitleColor(.label, for: .normal)
                self.calendarView.scrollToCurrentMonth()
            }
            self.monthPicker.isHidden.toggle()
            self.nextMonth.isHidden.toggle()
            self.previousMonth.isHidden.toggle()
            self.calendarView.isHidden.toggle()
            self.weekdaysView.isHidden.toggle()
        }

    }
    
}
