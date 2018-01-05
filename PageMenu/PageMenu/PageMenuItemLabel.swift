
import UIKit

open class PageMenuItemLabel: PageMenuItem
{
    open var titleLabel : UILabel!
    
    override var isSelected: Bool
        {
        didSet
        {
            guard isSelected != oldValue else { return }
            titleLabel.textColor = isSelected ? selectedColor : unselectedColor
        }
    }
    
    
    fileprivate let selectedColor: UIColor
    fileprivate let unselectedColor: UIColor
    
    required public init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(frame: CGRect, topOffset: CGFloat, title: String, selectedColor: UIColor, unselectedColor: UIColor)
    {
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        super.init(frame: frame)
        
        let labelFrame = CGRect(x: 0.0, y: topOffset, width: self.frame.size.width, height: self.frame.size.height - topOffset)
        titleLabel = UILabel(frame:labelFrame)
        titleLabel.numberOfLines = 0
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = unselectedColor
        self.addSubview(titleLabel!)
    }
}
