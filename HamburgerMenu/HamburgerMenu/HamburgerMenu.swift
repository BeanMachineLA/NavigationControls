import Foundation
import UIKit

public class HamburgerMenu: UIButton
{
    public var borderWidth: CGFloat = 0.0 {
        willSet { ringView.layer.borderWidth = newValue }
    }
    
    public var borderColor: CGColorRef = UIColor.clearColor().CGColor {
        willSet { ringView.layer.borderColor = newValue }
    }
    
    public var badgeType: HamburgerBadgeType {
        get { return badge.type }
        set { badge.type = newValue }
    }
    
    public var badgeOffset: CGPoint = CGPointZero {
        willSet{ badge.center = CGPointMake(badgeInitialPos.x + newValue.x, badgeInitialPos.y + newValue.y) }
    }
    
    private var menuIconImageView: UIImageView?
    private var backIconImageView: UIImageView?
    private var blurredView: UIVisualEffectView!
    private var ringView: UIView!
    private var badgeInitialPos: CGPoint!
    private var badge: HamburgerBadge!
    public convenience init(center: CGPoint, size: CGSize, menuIconImageName: String, backIconImageName: String, backButtonPositionOffset:CGPoint = CGPointMake(0, 0))
    {
        let frame: CGRect = CGRectMake(center.x - size.width/2.0, center.y - size.height/2.0, size.width, size.height)
        self.init(frame: frame)
        let menuLocalCenter = CGPointMake(frame.size.width/2.0, frame.size.height/2.0)
        
        let menuIconImage = UIImage(named: menuIconImageName)
        menuIconImageView = UIImageView(image: menuIconImage)
        menuIconImageView?.center = menuLocalCenter
        if let icon = menuIconImageView { self.addSubview(icon) }
        
        let backIconImage = UIImage(named: backIconImageName)
        backIconImageView = UIImageView(image: backIconImage)
        backIconImageView?.center = CGPointMake(menuLocalCenter.x + backButtonPositionOffset.x, menuLocalCenter.y + backButtonPositionOffset.y)
        backIconImageView?.hidden = true
        if let icon = backIconImageView { self.addSubview(icon) }
        
        let backFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        let blurEffect = UIBlurEffect(style: .Dark)
        blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        blurredView.frame = backFrame
        blurredView.layer.cornerRadius = frame.size.height/2.0
        blurredView.layer.masksToBounds = true
        blurredView.userInteractionEnabled = false
        self.insertSubview(blurredView, atIndex: 0)
        
        ringView = UIView(frame: backFrame)
        ringView.userInteractionEnabled = false
        ringView.layer.cornerRadius = frame.size.height/2.0
        ringView.layer.masksToBounds = true
        ringView.layer.borderColor = UIColor(red: 84.0/255.0, green: 84.0/255.0, blue: 84.0/255.0, alpha: 1.0).CGColor
        ringView.layer.borderWidth = 0.5
        self.insertSubview(ringView, atIndex: 0)
        
        //setup menu badge
        let menuRadius: CGFloat = frame.size.height/2.0
        let badgeY: CGFloat = menuRadius * (1.0 - CGFloat(sin(M_PI_4))) - 2.0
        let badgeX: CGFloat = menuRadius * (1.0 + CGFloat(cos(M_PI_4))) + 2.0
        badgeInitialPos = CGPointMake(badgeX, badgeY)
        badge = HamburgerBadge(center: badgeInitialPos)
        self.addSubview(badge)
        badgeOffset = CGPointMake(2.0, -2.0)
    }
    
    func appplyButtonState(state: HamburgerMenuState)
    {
        switch state
        {
        case .Close:
            blurredView.hidden = false
            menuIconImageView?.hidden = false
            ringView.hidden = true
            backIconImageView?.hidden = true
            self.hidden = false
            self.enabled = true
        case .Open:
            blurredView.hidden = true
            menuIconImageView?.hidden = false
            ringView.hidden = false
            backIconImageView?.hidden = true
            self.hidden = false
            self.enabled = true
        case .Back:
            blurredView.hidden = false
            menuIconImageView?.hidden = true
            backIconImageView?.hidden = false
            ringView.hidden = true
            self.hidden = false
            self.enabled = true
        case .Disable:
            self.hidden = true
            self.enabled = false
            break
        }
        showChangeStateAnimation(state)
    }
    
    private func showChangeStateAnimation(state: HamburgerMenuState)
    {
        switch state
        {
        case .Close:
            runRotateMenuIconAnimation (CGFloat(0.0), duration: 0.2)
        case .Open:
            runRotateMenuIconAnimation (CGFloat(-M_PI_2), duration: 0.2)
        case .Back:
            runBackButtonAppearAnimation()
        case .Disable:
            break
        }
    }
    
    private func runRotateMenuIconAnimation(angle: CGFloat, duration: CGFloat)
    {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            if let menuIconImageView = self.menuIconImageView
            { menuIconImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle) }
        })
    }
    
    private func runBackButtonAppearAnimation()
    {
        let bounceAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath:"transform.scale")
        bounceAnimation.values = [0.9, 1.1, 0.95, 1.0];
        bounceAnimation.keyTimes = [0.0, 0.2, 0.75, 1.0];
        bounceAnimation.duration = 0.2;
        backIconImageView?.layer.addAnimation(bounceAnimation, forKey:"bounce");
    }
}
