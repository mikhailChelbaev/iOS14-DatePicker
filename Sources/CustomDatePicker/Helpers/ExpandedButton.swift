import UIKit

fileprivate extension UIEdgeInsets {
    
    func inverted() -> UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
}

class ExpandedButton: UIButton {
    
    var touchAreaPadding: UIEdgeInsets? = .init(top: 10, left: 10, bottom: 10, right: 10)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let insets = touchAreaPadding else {
                    return super.point(inside: point, with: event)
                }
        let rect = bounds.inset(by: insets.inverted())
        return rect.contains(point)
    }
    
}
