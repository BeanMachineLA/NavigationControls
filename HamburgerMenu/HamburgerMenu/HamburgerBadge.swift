import Foundation
import UIKit

private extension Int {
    func clamp(minVal: Int, _ maxVal: Int) -> Int {
        let highBounded = Swift.min(self, maxVal)
        return Swift.max(minVal, highBounded)
    }
}

public enum HamburgerBadgeType {
    case None
    case Mark
    case Number(Int)
    case Text(String)
}

extension HamburgerBadgeType: Equatable {}

public func == (lhs: HamburgerBadgeType, rhs: HamburgerBadgeType) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None):
        return true
    case (.Mark, .Mark):
        return true
    case (.Number(let a), .Number(let b)) where a == b:
        return true
        
    default:
        return false
    }
}

public class HamburgerBadge: UIView {
    
    public var type = HamburgerBadgeType.None {
        didSet {
            switch type {
            case .None:
                markView.hidden = true
                badgeLabel.hidden = true
            case .Mark:
                markView.hidden = false
                badgeLabel.hidden = true
            case .Number(let dNumaber):
                let number = dNumaber.clamp(0, 99)
                badgeLabel.text = String(number)
                number == 0 ? (badgeLabel.hidden = true) : (badgeLabel.hidden = false)
                number >= 10 ? (badgeLabel.frame.size.width = 20) : (badgeLabel.frame.size.width = 14)
                markView.hidden = true
            case .Text(var text):
                if text.characters.count > 2 {
                    text = text.substringToIndex(text.startIndex.advancedBy(2))
                }
                badgeLabel.text = text
                text.characters.count == 2 ? (badgeLabel.frame.size.width = 20) : (badgeLabel.frame.size.width = 14)
                badgeLabel.hidden = false
                markView.hidden = true
            }
        }
    }
    
    public var badgeTextColor: UIColor {
        get { return badgeLabel.textColor }
        set { badgeLabel.textColor = newValue }
    }
    
    public var badgeBackgroundColor: UIColor {
        get { return badgeLabel.backgroundColor ?? standardBgColor }
        set { badgeLabel.backgroundColor = newValue }
    }
    
    public var markBackgroundColor: UIColor {
        get { return markView.backgroundColor ?? standardBgColor }
        set { markView.backgroundColor = newValue }
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private var badgeLabel: UILabel!
    private var markView: UIView!
    private var standardBgColor = UIColor(red: 233.0/255.0, green: 90.0/255.0, blue: 67.0/255.0, alpha: 1.0)
    public init (center: CGPoint)
    {
        let width: CGFloat = 20.0
        let height: CGFloat = 14.0
        let frame = CGRectMake(center.x - width/2.0, center.y - width/2.0, width, height)
        super.init(frame: frame)
        self.userInteractionEnabled = false
        
        badgeLabel = UILabel(frame: CGRectMake(0, 0, 20, 14))
        badgeLabel.center = center
        badgeLabel.font = UIFont.boldSystemFontOfSize(10)
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = .Center
        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.height/2.0
        badgeLabel.backgroundColor = standardBgColor
        badgeLabel.hidden = true
        badgeLabel.textColor = UIColor.whiteColor()
        self.addSubview(badgeLabel)
        
        markView = UIView(frame: CGRectMake(0, 0, 14, 14))
        markView.layer.cornerRadius = 7
        markView.layer.masksToBounds = true
        markView.backgroundColor = standardBgColor
        markView.hidden = true
        self.addSubview(markView)
        
        let markDot = UIView(frame: CGRectMake(5, 5, 4, 4))
        markDot.layer.cornerRadius = 2
        markDot.layer.masksToBounds = true
        markDot.backgroundColor = UIColor.whiteColor()
        markView.addSubview(markDot)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPointMake(bounds.width/2.0, bounds.height/2.0)
        markView.center = center
        badgeLabel.center = center
    }
}