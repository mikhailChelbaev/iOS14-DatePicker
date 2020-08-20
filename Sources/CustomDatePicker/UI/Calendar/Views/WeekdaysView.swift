import UIKit

class WeekdaysView: UICollectionView {
    
    weak var datePickerDelegate: CustomDatePickerDelegate?
    
    private let cellsInfo: [(type: AnyClass, id: String)] = [
        (type: WeekDayNameCell.self, id: "WeekDayNameCell")
    ]
    
    override var intrinsicContentSize: CGSize {
        .calculateWeekdaysViewSize()
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        
        registerCells()
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func registerCells() {
        for cell in cellsInfo {
            register(cell.type, forCellWithReuseIdentifier: cell.id)
        }
    }
        
}

extension WeekdaysView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        dequeueReusableCell(withReuseIdentifier: cellsInfo[0].id, for: indexPath)
    }
}

extension WeekdaysView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .calculateWeekdayCellSize(bounds: datePickerDelegate?.bounds)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? WeekDayNameCell, let calendar = datePickerDelegate?.calendar {
            cell.weekday.text = calendar.shortWeekdaySymbols[(indexPath.item + calendar.firstWeekday - 1) % 7].uppercased()
        }
    }
    
}
