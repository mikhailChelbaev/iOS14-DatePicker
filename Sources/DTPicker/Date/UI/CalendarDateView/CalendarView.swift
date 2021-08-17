import UIKit

protocol DPCalendar: ConfigurableView {
    var mediator: MonthChangeMediator? { set get }
    var datePickerDelegate: __DatePickerDelegate? { set get }
    
    func setCalendarData(_ data: CalendarData)
    func scrollToMonth(_ date: CDate, animated: Bool)
}

class CalendarView: UIView, DPCalendar {
    
    var data: CalendarData
    
    var config: DTConfig?
    
    weak var mediator: MonthChangeMediator?
    
    weak var datePickerDelegate: __DatePickerDelegate?
    
    private let reuseId: String = "cellId"
    
    private var numberOfMonths: Int = 0
    
    private var currentIndex: Int = 0
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    override init(frame: CGRect) {
        data = .default
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(collectionView)
        collectionView.stickToSuperviewEdges(.all)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CalendarMonthCell.self, forCellWithReuseIdentifier: reuseId)
    }
    
    func updateConfig(new config: DTConfig) {
        self.config = config
    }
    
    func setCalendarData(_ data: CalendarData) {
        self.data = data
        
        numberOfMonths = data.minDate.numberOfMonths(to: data.maxDate)
        
        collectionView.reloadData()
        
        scrollToMonth(data.selectedDateOrToday)
    }
    
    func scrollToMonth(_ date: CDate, animated: Bool = true) {
        guard let ip = indexPath(for: date) else { return }
        collectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: animated)
        mediator?.didChangeMonth(date)
    }
    
    func date(for indexPath: IndexPath) -> CDate? {
        return data.minDate.addingMonths(indexPath.item)
    }
    
    func indexPath(for date: CDate) -> IndexPath? {
        let item = data.minDate.numberOfMonths(to: date) - 1
        if item > numberOfMonths { return nil }
        return IndexPath(item: item, section: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollToMonth(data.selectedDateOrToday, animated: false)
    }
    
}

extension CalendarView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfMonths
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath)
        if let cell = cell as? CalendarMonth {
            if let config = config {
                cell.updateConfig(new: config)
            }
            cell.date = data.minDate.addingMonths(indexPath.item).beginOfMonth()
            cell.setCalendarData(data)
            cell.datePickerDelegate = self
        }
        return cell
    }
    
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        bounds.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var indexes = collectionView.indexPathsForVisibleItems
        indexes.sort()
        guard var index = indexes.first else { return }
        guard let cell = collectionView.cellForItem(at: index) else { return }
        let position = collectionView.contentOffset.x - cell.frame.origin.x
        if position > cell.frame.size.width / 2 {
            index.row = index.row + 1
        }
        
        if collectionView.isDragging, index.item != currentIndex  {
            let date = data.minDate.addingMonths(index.item)
            currentIndex = index.item
            mediator?.didChangeMonth(date)
        }
    }
    
}

extension CalendarView: __DatePickerDelegate {
    
    func dateDidChanged(to newDate: Date) {
        datePickerDelegate?.dateDidChanged(to: newDate)
    }
    
}
