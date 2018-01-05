
import Foundation
import UIKit

public class HamburgerLabelItem: HamburgerItem
{
    private let kInfoLabelHeight : CGFloat = 20.0
    private let kInfoLabelFontSize : CGFloat = 18.0
    private let kTitleLabelHeight : CGFloat = 14.0
    private let kTitleLabelFontSize : CGFloat = 12.0
    private let kInfoAndTitleLabelGap : CGFloat = 0.0
    
    public var infolabel: UILabel!
    public var itemTitleLabel: UILabel!
    
    public var infoSelectedTextColor = UIColor(red: 233.0/255.0, green: 90.0/255.0, blue: 67.0/255.0, alpha: 1.0)
    public var infoUnselectedTextColor = UIColor.whiteColor()
    public var titleSelectedTextColor = UIColor(red: 233.0/255.0, green: 90.0/255.0, blue: 67.0/255.0, alpha: 0.5)
    public var titleUnselectedTextColor = UIColor(white: 1.0, alpha: 0.5)
    
    
    override public var isItemSelected: Bool
    {
        willSet
        {
            if newValue
            {
                infolabel.textColor = infoSelectedTextColor
                itemTitleLabel.textColor = titleSelectedTextColor
            }
            else
            {
                infolabel.textColor = infoUnselectedTextColor
                itemTitleLabel.textColor = titleUnselectedTextColor
            }
        }
    }
    
    public convenience init(center: CGPoint, size: CGSize, info: String, title: String, tapCallback: ItemTapCallback? = nil)
    {
        self.init(center:center, size:size, tapCallback:tapCallback)
        
        //info label creation
        let infoLabelY = (size.height - (kTitleLabelHeight + kInfoAndTitleLabelGap + kInfoLabelHeight))/2.0
        let infoLabelFrame = CGRectMake(0, infoLabelY, size.width, kInfoLabelHeight)
        infolabel = UILabel(frame: infoLabelFrame)
        infolabel.font = UIFont.boldSystemFontOfSize(kInfoLabelFontSize)
        infolabel.textColor = UIColor.whiteColor()
        infolabel.textAlignment = .Center;
        infolabel.text = info
        self.addSubview(infolabel)
    

        //title label creation
        let titleLabelY = infoLabelY + kInfoLabelHeight + kInfoAndTitleLabelGap
        let titleLabelFrame = CGRectMake(0, titleLabelY, size.width, kTitleLabelHeight)
        itemTitleLabel = UILabel(frame: titleLabelFrame)
        itemTitleLabel.font = UIFont.systemFontOfSize(kTitleLabelFontSize)
        itemTitleLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        itemTitleLabel.textAlignment = .Center;
        itemTitleLabel.text = title
        self.addSubview(itemTitleLabel)
    }
}
