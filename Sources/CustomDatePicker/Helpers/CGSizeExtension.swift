import UIKit

extension CGSize {
    
    // MARK: - calendar
    
    static func calculateDateCellSize(bounds: CGRect? = nil, numberOfWeeks: Int = 5) -> CGSize {
        let viewWidth = bounds?.size.width ?? .defaultWidth
        let width = viewWidth / 7
        let height = width * CGFloat(5) / CGFloat(numberOfWeeks)
        return .init(width: width, height: height)
    }
    
    static func calculateMonthViewSize(bounds: CGRect? = nil) -> CGSize {
        let width = bounds?.size.width ?? .defaultWidth
        var height: CGFloat!
        if let bounds = bounds {
            height = bounds.size.height - .weekdayCellHeight - .monthButtonHeight
        } else {
            height = CGSize.calculateDateCellSize().height * 5
        }
        return .init(width: width, height: height)
    }
    
    // MARK: - weekdays view
    
    static func calculateWeekdayCellSize(bounds: CGRect? = nil) -> CGSize {
        let viewWidth = bounds?.size.width ?? .defaultWidth
        let width = viewWidth / 7
        return .init(width: width, height: .weekdayCellHeight)
    }
    
    static func calculateWeekdaysViewSize(bounds: CGRect? = nil) -> CGSize {
        let width = bounds?.size.width ?? .defaultWidth
        return .init(width: width, height: .weekdayCellHeight)
    }
}
