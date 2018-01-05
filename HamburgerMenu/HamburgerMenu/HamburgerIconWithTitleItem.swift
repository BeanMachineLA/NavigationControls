
import Foundation
import UIKit

public class HamburgerIconWithTitleItem: HamburgerItem
{
    private let kTitleLabelHeight : CGFloat = 14.0
    private let kTitleLabelFontSize : CGFloat = 12.0
    private let kIconAndLabelGap : CGFloat = 2
    
    public var iconImageView: HamburgerItemIcon?
    public var itemTitleLabel : UILabel!
    
    public var selectedTextColor = UIColor(red: 233.0/255.0, green: 90.0/255.0, blue: 67.0/255.0, alpha: 1.0)
    public var unselectedTextColor = UIColor.whiteColor()
    
    override public var isItemSelected: Bool 
    {
        willSet {
            if newValue
            {
                itemTitleLabel.textColor = selectedTextColor
                iconImageView?.iconColor = selectedTextColor
            }
            else
            {
                itemTitleLabel.textColor = unselectedTextColor
                iconImageView?.iconColor = unselectedTextColor
            }
        }
    }
    
    public convenience init(center: CGPoint, size: CGSize, iconImageName: String, title: String, tapCallback: ItemTapCallback? = nil)
    {
        self.init(center:center, size:size, tapCallback:tapCallback)

        //icon image creation
        let image = UIImage(named:iconImageName)
        iconImageView = HamburgerItemIcon(image: image)
        let iconCenterY = size.height/2.0 - (kTitleLabelHeight + kIconAndLabelGap)/2.0
        iconImageView?.center = CGPointMake(size.width/2.0, iconCenterY)
        if let iconView = iconImageView { self.addSubview(iconView) }
        
        
        //title label creation
        let imageHeight = image?.size.height ?? 0
        let labelY = iconCenterY + imageHeight/2.0 + kIconAndLabelGap
        let labelFrame = CGRectMake(0, labelY, size.width, kTitleLabelHeight)
        itemTitleLabel = UILabel(frame: labelFrame)
        itemTitleLabel.font = UIFont.systemFontOfSize(kTitleLabelFontSize)
        itemTitleLabel.textColor = UIColor.whiteColor()
        itemTitleLabel.textAlignment = .Center;
        itemTitleLabel.text = title
        self.addSubview(itemTitleLabel)
    }
}
