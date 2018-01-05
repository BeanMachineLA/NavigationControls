import UIKit

open class PageMenuItemIcon: PageMenuItem
{
    fileprivate var iconImageView : UIImageView!
    fileprivate var selectedImage : UIImage!
    fileprivate var unselectedImage : UIImage!
    fileprivate var topOffset : CGFloat = 0.0
    
    override var isSelected: Bool
    {
        didSet
        {
            if isSelected
            {
                iconImageView.frame.size = selectedImage.size
                iconImageView.center = CGPoint(x: self.frame.size.width/2.0, y: topOffset)
                iconImageView.image = selectedImage
            }
            else
            {
                iconImageView.frame.size = unselectedImage.size
                iconImageView.center = CGPoint(x: self.frame.size.width/2.0, y: topOffset)
                iconImageView.image = unselectedImage
            }
        }
    }
    
    
    required public init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(frame: CGRect, selectedIcon: UIImage, unselectedIcon: UIImage, topOffset: CGFloat)
    {
        super.init(frame: frame)

        iconImageView = UIImageView(frame: CGRect.zero)
        self.addSubview(iconImageView)
        
        self.topOffset = topOffset
        self.selectedImage = selectedIcon
        self.unselectedImage = unselectedIcon
    }
}
