import UIKit

protocol CalendarMonth: ConfigurableView {
    var date: CDate { set get }
    var datePickerDelegate: __DatePickerDelegate? { set get }
    
    func setCalendarData(_ data: CalendarData)
}

class CalendarMonthCell: UICollectionViewCell, CalendarMonth {
    
    var date: CDate
    
    var config: DTConfig?
    
    weak var datePickerDelegate: __DatePickerDelegate?
    
    private var data: CalendarData
    
    private let reuseId: String = "cellId"
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        return cv
    }()
    
    override init(frame: CGRect) {
        self.date = Date().cdate()
        self.data = .default
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(collectionView)
        collectionView.stickToSuperviewEdges(.all)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: reuseId)
    }
    
    func updateConfig(new config: DTConfig) {
        self.config = config
    }
    
    func setCalendarData(_ data: CalendarData) {
        self.data = data
        collectionView.reloadData()
    }
    
    private func dateForCell(at indexPath: IndexPath) -> CDate? {
        if date.firstWeekdayInMonth <= indexPath.item && indexPath.item < date.numberOfDays + date.firstWeekdayInMonth {
            let result = date
            date.increaseDays()
            return result
        }
        return nil
    }
    
}

extension CalendarMonthCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 * date.numberOfWeeks
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath)
        if let cell = cell as? CalendarDay {
            if let config = config {
                cell.updateConfig(new: config)
            }
            cell.update(date: dateForCell(at: indexPath), data: data)
        }
        return cell
    }
    
}

extension CalendarMonthCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor(bounds.width / 7)
        let height = bounds.height / CGFloat(date.numberOfWeeks)
        return .init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CalendarDay, let date = cell.date, date >= data.minDate, date <= data.maxDate {
            datePickerDelegate?.dateDidChanged(to: date.toDate())
        }
    }
    
}
