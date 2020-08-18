//
//  MonthView.swift
//  DPicker
//
//  Created by Mikhail on 17.07.2020.
//

import SwiftUI

class MonthView: UICollectionView {
    
    // MARK: - internal fields
    
    weak var datePickerDelegate: CustomDatePickerDelegate?
    
    var dateComponents: DateComponents! {
        didSet {
            firstDay = calendar.date(from: dateComponents)
            currentDay = firstDay
            let days = (weekday + (calendar.range(of: .day, in: .month, for: firstDay)?.count ?? 0)) - 1
            numberOfWeeks = days / 7 + (days % 7 == 0 ? 0 : 1)
            reloadData()
        }
    }
    
    var page: Int = 0
    
    // MARK: - private fields
    
    private let cellsInfo: [(type: AnyClass, id: String)] = [
        (type: DateCell.self, id: "DateCell")
    ]
    
    private var calendar: Calendar! {
        datePickerDelegate?.calendar
    }
    
    private var firstDay: Date!
    
    // initialy it is the first day of the month
    private var currentDay: Date!
    
    private var weekday: Int {
        let weekday = (calendar.component(.weekday, from: currentDay) - calendar.firstWeekday + 1) % 7
        return weekday == 0 ? 7 : weekday
    }
    
    private var numberOfWeeks = 0
    
    // MARK: - init
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
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

// MARK: - UICollectionViewDataSource

extension MonthView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfWeeks * 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: cellsInfo[0].id, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DateCell,
              cell.style != .empty else { return }
        cell.select()
        datePickerDelegate?.date = cell.cellDate!
        
        if let selectedCellIndex = datePickerDelegate?.selectedCellIndex,
           selectedCellIndex.page == page,
           selectedCellIndex.item != indexPath.item,
           let cell = collectionView.cellForItem(at: IndexPath(item: selectedCellIndex.item, section: 0)) as? DateCell {
            cell.deselect()
            if cell.style != .empty {
                datePickerDelegate?.date = cell.cellDate!
            }
        }
        datePickerDelegate?.selectedCellIndex = (page: page, item: indexPath.item)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MonthView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .calculateDateCellSize(bounds: datePickerDelegate?.bounds, numberOfWeeks: numberOfWeeks)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? DateCell {
            cell.pickerTintColor = datePickerDelegate?.tintColor
            
            if indexPath.item % 7 + 1 == weekday && calendar.component(.month, from: currentDay) == dateComponents.month {
                cell.style = .date(currentDay)
                currentDay.addTimeInterval(24 * 60 * 60)
            } else {
                cell.style = .empty
            }
            
            if let delegate = datePickerDelegate,
               delegate.selectedCellIndex.page == page,
               delegate.selectedCellIndex.item == indexPath.item {
                cell.select()
            }
        }
    }

}
