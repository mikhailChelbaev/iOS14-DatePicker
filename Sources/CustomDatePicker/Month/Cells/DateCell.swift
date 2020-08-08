//
//  DateCell.swift
//  DPicker
//
//  Created by Mikhail on 17.07.2020.
//

import UIKit

enum DateCellStyle: Equatable {
    case empty, date(Date)
}

class DateCell: UICollectionViewCell {
    
    private let calendar = Calendar.current
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view.layer.cornerRadius = (min(bounds.size.width, bounds.size.height) - 2) / 2
        let side = min(bounds.size.width, bounds.size.height)
        viewConstraints?.width?.constant = side - 1
        viewConstraints?.height?.constant = side - 1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = ""
        dateLabel.textColor = .customLabel
        dateLabel.font = .systemFont(ofSize: 20, weight: .regular)
        view.backgroundColor = .customBackground
    }
    
    private func anchorItems() {
        addSubview(view)
        viewConstraints = view.anchorToCenter(parent: self, size: .init(width: 1, height: 1))
        
        view.addSubview(dateLabel)
        dateLabel.anchorToCenter(parent: view)
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
        dateLabel.textColor = flag ? pickerTintColor : .customLabel
        dateLabel.font = .systemFont(ofSize: 20, weight: .regular)
        view.backgroundColor = .customBackground
    }
    
}
