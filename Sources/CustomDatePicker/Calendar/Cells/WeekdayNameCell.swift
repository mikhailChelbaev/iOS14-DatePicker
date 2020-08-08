//
//  WeekdayNameCell.swift
//  DPicker
//
//  Created by Mikhail on 18.07.2020.
//

import UIKit

class WeekDayNameCell: UICollectionViewCell {
    
    let weekday: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .customGray3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        anchorItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func anchorItems() {
        addSubview(weekday)
//        weekday.anchor(bottom: bottomAnchor, padding: .init(top: 0, left: 0, bottom: 5, right: 0))
//        weekday.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        weekday.anchorToCenter(parent: self)
    }
    
}
