import Foundation
import UIKit

public class HamburgerIconWithTitleAndBadgeItem: HamburgerIconWithTitleItem
{
    public var badgeType: HamburgerBadgeType {
        get { return badge.type }
        set { badge.type = newValue }
    }
    
    public var badgeOffset: CGPoint = CGPointZero
    {
        willSet{ badge.center = CGPointMake(badgeInitialPos.x + newValue.x, badgeInitialPos.y + newValue.y) }
    }
    
    private var badgeInitialPos: CGPoint!
    private var badge: HamburgerBadge!
    public convenience init(center: CGPoint, size: CGSize, iconImageName: String, title: String, badgeNumber: Int, tapCallback: ItemTapCallback? = nil)
    {
        self.init(center:center, size:size, iconImageName:iconImageName, title:title, tapCallback:tapCallback)

        let frame = iconImageView?.frame ?? CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        badgeInitialPos = CGPointMake(frame.origin.x + frame.size.width + 5, frame.origin.y - 5)
        badge = HamburgerBadge(center: badgeInitialPos)
        self.addSubview(badge)
        badgeType = HamburgerBadgeType.Number(badgeNumber)
    }
}
