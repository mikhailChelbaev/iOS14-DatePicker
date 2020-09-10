import UIKit

enum DateCellStyle: Equatable {
    case empty, date(Date)
}

class DateCell: UICollectionViewCell {
    
    private let calendar = Calendar.current
    
    var cellIndex: (page: Int, item: Int) = (0, 0)
    
    var style: DateCellStyle! {
        didSet {
            switch style {
            case .date(let cellDate):
                self.cellDate = cellDate
                dateLabel.text = String(describing: Calendar.current.component(.day, from: cellDate))
                if isToday() {
                    dateLabel.textColor = pickerTintColor
                }
            default:
                return
            }
        }
    }
    
    var pickerTintColor: UIColor?
    
    private(set) var cellDate: Date?
    
    private var viewConstraints: AnchoredConstraints?
    
    private let view = UIView()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        anchorItems()
        setupNotifications()
        clipsToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view.layer.cornerRadius = bounds.width / 2
        viewConstraints?.width?.constant = bounds.width
        viewConstraints?.height?.constant = bounds.width
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = ""
        dateLabel.textColor = .label
        dateLabel.font = .systemFont(ofSize: 20, weight: .regular)
        view.backgroundColor = .customBackground
    }
    
    private func anchorItems() {
        addSubview(view)
        viewConstraints = view.anchorToCenter(parent: self, size: .init(width: 1, height: 1))
        
        view.addSubview(dateLabel)
        dateLabel.anchorToCenter(parent: view)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(checkSelectNotification), name: .select, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkDeselectNotification), name: .deselect, object: nil)
    }
    
    private func isToday() -> Bool {
        guard let cellDate = cellDate else { return false }
        return calendar.dateComponents([.year, .month, .day], from: cellDate) == calendar.dateComponents([.year, .month, .day], from: Date())
    }
    
    func select() {
        if style == .empty { return }
        let flag = isToday()
        dateLabel.textColor = flag ? .white : pickerTintColor
        dateLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        view.backgroundColor = flag ? pickerTintColor : pickerTintColor!.withAlphaComponent(0.1)
    }
    
    func deselect() {
        if style == .empty { return }
        let flag = isToday()
        dateLabel.textColor = flag ? pickerTintColor : .label
        dateLabel.font = .systemFont(ofSize: 20, weight: .regular)
        view.backgroundColor = .customBackground
    }
    
    // MARK: - notification handlers
    
    @objc private func checkSelectNotification(_ notification: Notification) {
        if let page = notification.userInfo?["page"] as? Int,
           let item = notification.userInfo?["item"] as? Int,
           cellIndex.page == page,
           cellIndex.item == item {
            select()
        }
    }
    
    @objc private func checkDeselectNotification(_ notification: Notification) {
        if let page = notification.userInfo?["page"] as? Int,
           let item = notification.userInfo?["item"] as? Int,
           cellIndex.page == page,
           cellIndex.item == item {
            deselect()
        }
    }
    
}
