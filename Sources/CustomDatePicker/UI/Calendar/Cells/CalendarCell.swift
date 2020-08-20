import UIKit

class CalendarCell: UICollectionViewCell {
    
    let monthView = MonthView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(monthView)
        monthView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
