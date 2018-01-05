
import Foundation
import UIKit

public class HamburgerItemIcon: UIView
{
    private var image: UIImage?
    public convenience init(image: UIImage?)
    {
        var frame = CGRectZero
        if let img = image { frame = CGRectMake(0, 0, img.size.width, img.size.height) }
        self.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = false
        self.opaque = false
        self.image = image
    }
    
    public var iconColor = UIColor(white: 202.0/255.0, alpha: 1.0)
    {
        willSet {self.setNeedsDisplay() }
    }
    
    public override func drawRect(rect: CGRect)
    {
        if let img = self.image
        {
            let bounds = self.bounds;
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, rect.maxX, rect.maxY)
            CGContextRotateCTM(context, CGFloat(M_PI))
            iconColor.set()
            CGContextClipToMask(context, bounds, img.CGImage);
            CGContextFillRect(context, bounds);
            CGContextRestoreGState(context);
        }
    }
}