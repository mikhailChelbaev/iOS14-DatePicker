import UIKit

protocol ShowMonthYearPickerDelegate: AnyObject {
    func showMonthYearPicker()
    func hideMonthYearPicker()
}

protocol ShowYearPicker: ConfigurableView {
    var isSelected: Bool { get }
    var delegate: ShowMonthYearPickerDelegate? { set get }
    
    func setTitleText(_ text: String)
}


class ShowYearPickerView: UIView, ShowYearPicker {
    
    private(set) var isSelected: Bool = false
    
    private(set) var config: DTConfig?
    
    weak var delegate: ShowMonthYearPickerDelegate?
    
    private let monthName = UILabel()
    
    private var image: UIImage? {
        let config: UIImage.SymbolConfiguration = .init(weight: .semibold)
        return UIImage(systemName: "chevron.right")?.withConfiguration(config)
    }
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    init() {
        super.init(frame: .zero)
        
        updateUI()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(monthName)
        monthName.stickToSuperviewEdges([.left, .top, .bottom], insets: .init(top: 0, left: 4, bottom: 0, right: 0))
        
        addSubview(imageView)
        imageView.leading(4, to: monthName)
        imageView.trailing(4)
        imageView.height(16)
        imageView.centerVertically()
    }
    
    private func updateUI() {
        if isSelected {
            monthName.textColor = config?.color
        } else {
            monthName.textColor = .label
        }
    }
    
    private func animateImageRotation() {
        UIView.animate(withDuration: 0.2) {
            self.imageView.transform = self.isSelected ? .init(rotationAngle: .pi / 2) : .identity
        }
    }
    
    func updateConfig(new config: DTConfig) {
        self.config = config
        monthName.font = config.font.withSize(17)
        imageView.image = image?.withTintColor(config.color, renderingMode: .alwaysOriginal)
    }
    
    func setTitleText(_ text: String) {
        monthName.text = text
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected.toggle()
        updateUI()
        animateImageRotation()
        if isSelected {
            delegate?.showMonthYearPicker()
        } else {
            delegate?.hideMonthYearPicker()
        }
    }
    
}
