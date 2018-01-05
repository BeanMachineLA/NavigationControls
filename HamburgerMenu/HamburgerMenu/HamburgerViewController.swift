import UIKit

public enum HamburgerMenuState
{
    case Close
    case Open
    case Back
    case Disable
}

public class HamburgerViewController: UIViewController
{
    public var onTapMenuButton:((HamburgerMenuState)->Void)?
    public var onTapMenuItem:((HamburgerMenuState)->Void)?
    public var onLongPressMenuButton: ((HamburgerMenuState)->Void)?
    
    public var onMenuStateChanged:((ps:HamburgerMenuState, ns:HamburgerMenuState)->Void)?
    public var onTapBackground:(()->Void)?
    
    public var menuState: HamburgerMenuState = .Close
    {
        willSet { applyMenuState(menuState, newValue) }
    }
    
    public var menuButton: HamburgerMenu!
    public var menuButtonPosition : CGPoint
    {
        get { return menuButton.center }
        set { menuButton.center = newValue }
    }
    
    public var menuButtonSize : CGSize
    {
        get { return menuButton.frame.size }
        set { menuButton.frame.size = newValue }
    }
    
    public var internalOpenClose: Bool = true
    
    private var menuItems: Array<HamburgerItem>!
    private var backgroundView: UIView!
    private weak var baseVC: UIViewController?
    public convenience init(baseVC: UIViewController, items: Array<HamburgerItem>, menu: HamburgerMenu)
    {
        //base initialization
        self.init()
        self.baseVC = baseVC
        baseVC.addChildViewController(self)
        baseVC.view.addSubview(self.view)
        
        //create swallower view
        backgroundView = SwallowView.generateSwallowView(.Gradient)
        backgroundView.alpha = 0.0
        self.view.addSubview(backgroundView)
        
        //setup menu items
        self.setupMenuItemsGrid(items)
        
        //create menu button
        menuButton = menu
        baseVC.view.addSubview(menuButton)
        
        menuButton.addTarget(self, action:"onMenuButtonTapped:", forControlEvents:.TouchUpInside)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressHandler:")
        menuButton.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    public override func loadView()
    {
        let screenBounds = UIScreen.mainScreen().bounds
        let view = UIView(frame: screenBounds)
        self.view = view
        self.view.userInteractionEnabled = false
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "backgroundTapped"))
    }
    
    func backgroundTapped()
    {
        onTapBackground?()
    }
    
    private func setupMenuItemsGrid(items: Array<HamburgerItem>)
    {
        menuItems = items
        var tagCounter: Int = 0
        let _ = menuItems.map{
            (item: HamburgerItem) -> () in
            self.view.addSubview(item)
            item.tag = tagCounter
            item.center = item.initialPosition
            item.deactivate()
            item.addTarget(self, action: "onItemTapped:", forControlEvents: .TouchUpInside)
            tagCounter++
        }
    }
    
    public func onItemTapped(item: HamburgerItem)
    {
        item.playItemTappedAnimation{ [weak self] in if let s = self { s.onTapMenuItem?(s.menuState) } }
    }
    
    private func applyMenuState(previousState:HamburgerMenuState, _ nextState:HamburgerMenuState)
    {
        menuButton.appplyButtonState(nextState)
        switch nextState
        {
        case .Open:
            baseVC?.view.bringSubviewToFront(self.view)
            baseVC?.view.bringSubviewToFront(menuButton)
            showSwallowerView()
            self.view.userInteractionEnabled = true
            let _ = menuItems.map{item in item.activateWithAnimation()}
            
        case .Close,
        .Back,
        .Disable:
            hideSwallowerView()
            self.view.userInteractionEnabled = false
            let _ = menuItems.map{item in item.deactivate()}
        }
        onMenuStateChanged?(ps: previousState, ns: nextState)
    }
    
    public func showSwallowerView()
    {
        backgroundView.alpha = 0.0
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.backgroundView.alpha = 1.0
        })
    }
    
    public func hideSwallowerView()
    {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.backgroundView.alpha = 0.0
        })
    }
    
    //MARK: menu button events methods
    func onMenuButtonTapped(sender:UIButton)
    {
        onTapMenuButton?(menuState)
    }
    
    func longPressHandler(recognizer:UILongPressGestureRecognizer)
    {
        onLongPressMenuButton?(menuState)
    }
}
