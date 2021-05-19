import UIKit

typealias Weekdays = ConfigurableView

class WeekDaysView: Weekdays {
    
    var config: DTConfig?
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fillEqually
        return sv
    }()
    
    init() {
        super.init(frame: .zero)        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        addSubview(stackView)
        stackView.stickToSuperviewEdges(.all)
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemGray3
        label.text = text
        label.textAlignment = .center
        return label
    }
    
    func updateConfig(new config: DTConfig) {
        self.config = config
        
        let calendar = config.calendar
        
        let labels: [UILabel] = (0...6).map({
            let text = calendar.shortWeekdaySymbols[($0 + calendar.firstWeekday - 1) % 7].uppercased()
            return createLabel(text: text)
        })
        
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        labels.forEach({ self.stackView.addArrangedSubview($0) })
    }
    
}
