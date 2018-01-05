
import Foundation
import UIKit

public class HamburgerRoundImageItem: HamburgerItem
{
    public var badgeType: HamburgerBadgeType {
        get { return badge.type }
        set { badge.type = newValue }
    }
    
    public var badgeOffset: CGPoint = CGPointZero
    {
        willSet{ badge.center = CGPointMake(badgeInitialPos.x + newValue.x, badgeInitialPos.y + newValue.y) }
    }
    
    private(set) var imageRadius: CGFloat = 0.0
    {
        didSet
        {
            if changeBadgePositionDependOnImageSize
            {
                let badgeXOffset: CGFloat = imageRadius * CGFloat(cos(M_PI_4))
                let badgeYOffset: CGFloat = imageRadius * CGFloat(sin(M_PI_4))
                let centerX = self.frame.width / 2.0
                let centerY = self.frame.height / 2.0
                badgeInitialPos = CGPointMake(centerX + badgeXOffset, centerY - badgeYOffset)
                badge.center = CGPointMake(badgeInitialPos.x + badgeOffset.x, badgeInitialPos.y + badgeOffset.y)
            }
        }
    }
    
    public var changeBadgePositionDependOnImageSize = true
    private var badgeInitialPos: CGPoint!
    private var badge: HamburgerBadge!
    private var iconImageView: UIImageView!
    public convenience init(center: CGPoint, size: CGSize, iconImageName: String, tapCallback: ItemTapCallback? = nil)
    {
        self.init(center:center, size:size, tapCallback:tapCallback)
        
        //setup badge
        let radius: CGFloat = frame.size.height/2.0
        let badgeY: CGFloat = radius * (1.0 - CGFloat(sin(M_PI_4))) - 2.0
        let badgeX: CGFloat = radius * (1.0 + CGFloat(cos(M_PI_4))) + 2.0
        badgeInitialPos = CGPointMake(badgeX, badgeY)
        badge = HamburgerBadge(center: badgeInitialPos)
        self.addSubview(badge)
        badgeOffset = CGPointMake(2.0, -2.0)
        
        
        //setup round image view
        iconImageView = UIImageView(frame: CGRectMake(0, 0, size.width, size.height))
        iconImageView.layer.masksToBounds = true
        self.insertSubview(iconImageView, atIndex:0)
        setRoundImageWithName(iconImageName)
    }
    
    public func setRoundImageWithName(imageName:String)
    {
        let image = UIImage(named:imageName)
        setRoundImage(image)
    }
    
    public func setRoundImage(image:UIImage?)
    {
        if let img = image
        {
            let diameter = img.size.height
            let offsetX = (self.frame.size.width - diameter)/2.0
            let offsetY = (self.frame.size.height - diameter)/2.0
            iconImageView.frame = CGRectMake(offsetX, offsetY, diameter, diameter)
            iconImageView?.layer.cornerRadius = diameter/2.0
            iconImageView.image = img
            
            imageRadius = diameter / 2.0
        }
    }
}
