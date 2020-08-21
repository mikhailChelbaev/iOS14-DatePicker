import SwiftUI

class CalendarView: UICollectionView {
    
    // MARK: - fields
    
    weak var datePickerDelegate: CustomDatePickerDelegate? {
        didSet { scrollToCurrentMonth() }
    }
    
    private let cellsInfo: [(type: AnyClass, id: String)] = [
        (type: CalendarCell.self, id: "CalendarCell")
    ]
    
    // MARK: - override fields
    
    override var intrinsicContentSize: CGSize {
        .calculateMonthViewSize()
    }
    
    // MARK: - init
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private methods
    
    private func setupCollectionView() {
        dataSource = self
        delegate = self
        backgroundColor = .customBackground
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        
        for cell in cellsInfo {
            register(cell.type, forCellWithReuseIdentifier: cell.id)
        }
    }
    
    func scrollToMonth(_ components: DateComponents, animated: Bool = false) {
        if let dpDelegate = datePickerDelegate {
            let cellNum = (components.year! - dpDelegate.minimumDate.year!) * 12 + components.month!
            DispatchQueue.main.async {
                self.scrollToItem(at: IndexPath(row: cellNum, section: 0), at: .centeredHorizontally, animated: animated)
            }
        }
    }
    
    func scrollToCurrentMonth(animated: Bool = false) {
        if let components = datePickerDelegate?.currentComponents {
            scrollToMonth(components, animated: animated)
        }
    }
    
    private func getDateComponents(for indexPath: IndexPath) -> DateComponents? {
        guard let delegate = datePickerDelegate else { return nil }
        
        let month = indexPath.item % 12 == 0 ? 12 : indexPath.item % 12
        let year = delegate.minimumDate.year! + indexPath.item / 12 - (month == 12 ? 1 : 0)
        
        return .init(year: year, month: month)
    }
    
}

// MARK: - UICollectionViewDataSource

extension CalendarView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        datePickerDelegate?.numberOfCells ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellsInfo[0].id, for: indexPath) as! CalendarCell
        cell.monthView.datePickerDelegate = datePickerDelegate
        cell.monthView.page = indexPath.item
        if let components = getDateComponents(for: indexPath) {
            cell.monthView.dateComponents = components
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CalendarView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .calculateMonthViewSize(bounds: datePickerDelegate?.bounds)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var indexes = self.indexPathsForVisibleItems
        indexes.sort()
        var index = indexes.first!
        let cell = self.cellForItem(at: index)!
        let position = self.contentOffset.x - cell.frame.origin.x
        if position > cell.frame.size.width / 2 {
           index.row = index.row + 1
        }
        
        if isDragging, let components = getDateComponents(for: index) {
            datePickerDelegate?.currentComponents = components
        }
    }
    
}
