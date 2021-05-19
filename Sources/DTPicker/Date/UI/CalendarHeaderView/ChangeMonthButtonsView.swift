import UIKit

protocol ChangeMonthDelegate: AnyObject {
    func showPreviousMonth()
    func showNextMonth()
}

protocol ChangeMonthButtons: ConfigurableView {
    var delegate: ChangeMonthDelegate? { get set }
    var previousMonth: UIButton { get }
    var nextMonth: UIButton { get }
}

class ChangeMonthButtonsView: UIView, ChangeMonthButtons {
    
    var delegate: ChangeMonthDelegate?
    
    var config: DTConfig?
    
    let previousMonth: UIButton = {
        let button = UIButton()
        button.tag = -1
        button.setBackgroundImage(UIImage(systemName: "chevron.left"), for: .normal)
        return button
    }()
    
    let nextMonth: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.setBackgroundImage(UIImage(systemName: "chevron.right"), for: .normal)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        previousMonth.addTarget(self, action: #selector(changeMonth(_:)), for: .touchUpInside)
        nextMonth.addTarget(self, action: #selector(changeMonth(_:)), for: .touchUpInside)
        
        addSubview(previousMonth)
        previousMonth.stickToSuperviewEdges([.left, .top, .bottom])
        
        addSubview(nextMonth)
        nextMonth.stickToSuperviewEdges([.right, .top, .bottom])
        nextMonth.leading(28, to: previousMonth)
    }
    
    func updateConfig(new config: DTConfig) {
        self.config = config
        previousMonth.tintColor = config.color
        nextMonth.tintColor = config.color
    }
    
    @objc private func changeMonth(_ sender: UIButton) {
        if sender.tag == -1 {
            delegate?.showPreviousMonth()
        } else if sender.tag == 1 {
            delegate?.showNextMonth()
        }
    }
    
}
