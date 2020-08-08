//
//  ColorExtension.swift
//  DPicker
//
//  Created by Mikhail on 07.08.2020.
//

import UIKit

extension UIColor {
    static var customBackground: UIColor = .clear
    static var customGray3: UIColor = UIColor(named: "gray3", in: Bundle(for: CalendarView.self), compatibleWith: nil) ?? .gray
    static var customLabel: UIColor = UIColor(named: "label", in: Bundle(for: CalendarView.self), compatibleWith: nil) ?? .black
}
