import UIKit


public class HamburgerItem: UIButton
{
    public typealias ItemTapCallback = (item: HamburgerItem)->Void
    public var tapCallback: ItemTapCallback?
    
    public var initialPosition: CGPoint = CGPointZero
    
    public func activate()
    {
        self.alpha = 1.0
        self.enabled = true
    }
    
    public func deactivate()
    {
        self.alpha = 0.0
        self.enabled = false
    }
    
    public var isItemSelected: Bool = false
    
    public func activateWithAnimation(delay: Float = 0.0)
    {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(delay) * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.alpha = 0;
            self.hidden = false
            self.enabled = true
            UIView.animateWithDuration(0.2){ self.alpha = 1.0 }
            let bounceAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath:"transform.scale")
            bounceAnimation.values = [0.9, 1.1, 0.95, 1.0];
            bounceAnimation.keyTimes = [0.0, 0.2, 0.75, 1.0];
            bounceAnimation.duration = 0.2;
            self.layer.addAnimation(bounceAnimation, forKey:"bounce");
        }
    }
    
    public convenience init(center: CGPoint, size: CGSize, tapCallback: ItemTapCallback? = nil)
    {
        let frame: CGRect = CGRectMake(center.x - size.width/2.0, center.y - size.height/2.0, size.width, size.height)
        self.init(frame:frame)
        self.initialPosition = center
        self.tapCallback = tapCallback
    }
    
    public func playItemTappedAnimation(callback: ()->Void)
    {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.enabled = false
            self.alpha = 0.0
            self.transform = CGAffineTransformMakeScale(1.2, 1.2)
        })
        {
            (finished:Bool)->Void in
            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
            callback()
            if let itemCallback = self.tapCallback { itemCallback(item: self) }
        }
    }
}
