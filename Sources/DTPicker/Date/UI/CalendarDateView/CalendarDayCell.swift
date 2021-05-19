import UIKit

enum CalendarDayStyle {
    case enabled
    case disabled
    case selected
    case none
}

protocol CalendarDay: Configurable {
    var date: CDate? { get }
    
    func update(date: CDate?, data: CalendarData)
}

class CalendarDayCell: UICollectionViewCell, CalendarDay {
    
    var config: DTConfig?
    
    private var state: CalendarDayStyle
    
    var date: CDate?
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let view: UIView = UIView()
    
    private var viewConstraints: AnchoredConstraints?
    
    override init(frame: CGRect) {
        self.state = .enabled
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        contentView.addSubview(view)
        viewConstraints = view.stickToSuperviewEdges(.all)
        
        contentView.addSubview(dateLabel)
        dateLabel.stickToSuperviewEdges([.left, .right])
        dateLabel.centerVertically()
        
        contentView.clipsToBounds = false
        view.clipsToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let offset = abs(bounds.width - bounds.height) / 2
        view.layer.cornerRadius = min(bounds.height, bounds.width) / 2
        if bounds.width > bounds.height {
            viewConstraints?.leading?.constant = offset
            viewConstraints?.trailing?.constant = -offset
            viewConstraints?.top?.constant = 0
            viewConstraints?.bottom?.constant = 0
        } else {
            viewConstraints?.leading?.constant = 0
            viewConstraints?.trailing?.constant = 0
            viewConstraints?.top?.constant = offset
            viewConstraints?.bottom?.constant = -offset
        }
    }
    
    func updateConfig(new config: DTConfig) {
        self.config = config
        view.backgroundColor = config.color.withAlphaComponent(0.1)
    }
    
    func update(date: CDate?, data: CalendarData) {
        self.date = date
        if let date = date {
            if date < data.minDate || date > data.maxDate {
                self.state = .disabled
            } else if date == data.selectedDate {
                self.state = .selected
            } else {
                self.state = .enabled
            }
        } else {
            self.state = .none
        }
        updateUI()
    }
    
    private func updateUI() {
        switch state {
        case .none:
            dateLabel.text = " "
            view.isHidden = true
        case .disabled:
            dateLabel.text = "\(date?.day ?? 0)"
            dateLabel.textColor = .secondaryLabel.withAlphaComponent(0.2)
            view.isHidden = true
        case .enabled:
            dateLabel.text = "\(date?.day ?? 0)"
            dateLabel.textColor = .label
            view.isHidden = true
        case .selected:
            dateLabel.text = "\(date?.day ?? 0)"
            dateLabel.textColor = config?.color ?? .systemBlue
            view.isHidden = false
        }
    }
    
}
