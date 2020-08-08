//
//  LayoutExtension.swift
//  DPicker
//
//  Created by Mikhail on 17.07.2020.
//

import UIKit

// ---------------------------------------------------------------------------------------------
// struct to store view's constraints

public struct AnchoredConstraints {
    public var top, leading, bottom, trailing, width, height: NSLayoutConstraint?
}

// ---------------------------------------------------------------------------------------------
// extension to facilitate autolayout usage

public extension UIView {
    
    /// anchor to neighbours
    /// - Parameters:
    ///   - top: neightbour's top anchor
    ///   - leading: neightbour's leading anchor
    ///   - bottom: neightbour's bottom anchor
    ///   - trailing: neightbour's trailing anchor
    ///   - padding: padding from neighbours
    ///   - size: view's size
    /// - Returns: `AnchoredConstraints` instance
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                padding: UIEdgeInsets = .zero,
                size: CGSize = .zero) -> AnchoredConstraints {
        
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        
        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        
        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }
        
        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        
        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }
        
        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        
        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
        [anchoredConstraints.top,
         anchoredConstraints.leading,
         anchoredConstraints.bottom,
         anchoredConstraints.trailing,
         anchoredConstraints.width,
         anchoredConstraints.height].forEach{ $0?.isActive = true }
        
        return anchoredConstraints
    }
    
    /// anchor to parent's center
    /// - Parameters:
    ///   - parent: parent view
    ///   - size: view's size
    /// - Returns: `AnchoredConstraints` instance
    @discardableResult
    func anchorToCenter(parent: UIView,
                        padding: (vertical: CGFloat, horizontal: CGFloat) = (0, 0),
                        size: CGSize = .zero) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        
        centerYAnchor.constraint(equalTo: parent.centerYAnchor, constant: padding.vertical).isActive = true
        centerXAnchor.constraint(equalTo: parent.centerXAnchor, constant: padding.horizontal).isActive = true
        
        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        
        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
        [anchoredConstraints.width,
         anchoredConstraints.height].forEach{ $0?.isActive = true }
        
        return anchoredConstraints
    }
}


