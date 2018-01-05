
import UIKit
import ActionMenu
import HamburgerMenu
import PageMenu

private extension CGPoint
{
    func add(p:CGPoint)->CGPoint { return CGPointMake(self.x + p.x, self.y + p.y) }
}

class PagesViewController: UIViewController, HamburgerMenuObserver
{
    var pageMenu : PageMenu!
    var hamburgerController : HamburgerViewController!
    var actionMenuController : ActionMenuViewController!
    
    override func loadView()
    {
        self.view = UIView(frame: UIScreen.mainScreen().bounds)
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    func setupPageMenu()
    {        
        // MARK: setup internal page view controllers
        let controller1 : PageViewController = PageViewController(title: "Feed", color: UIColor.greenColor())
        let controller2 : PageViewController = PageViewController(title: "Highlights", color: UIColor.yellowColor())
        let controller3 : PageViewController = PageViewController(title: "Connect", color: UIColor.lightGrayColor())
        let controllerArray = [controller1, controller2, controller3]
        
        let imagesItem1 = (UIImage(named: "pageMenu_imagesIcon_selected")!, UIImage(named: "pageMenu_imagesIcon_unselected")!)
        let imagesItem2 = (UIImage(named: "pageMenu_soundcloudIcon_selected")!, UIImage(named: "pageMenu_soundcloudIcon_unselected")!)
        let imagesItem3 = (UIImage(named: "pageMenu_textIcon_selected")!, UIImage(named: "pageMenu_textIcon_unselected")!)
        let itemIcons : [(selectedIcon: UIImage, unselectedIcon: UIImage)] = [imagesItem1, imagesItem2, imagesItem3]
        
        // MARK: customize page menu (Optional)
        var parameters: [PageMenuOption] = [
            .SelectionIndicatorWidthPercent(90),
            .ScrollMenuBackgroundColor(UIColor.blackColor()),
            .ViewBackgroundColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)),
            .MenuHeight(51.0),
            .MenuItemWidth(150.0),
            .CenterMenuItems(true),
            .SelectionIndicatorColor(UIColor(red: 233.0/255.0, green: 90.0/255.0, blue: 67.0/255.0, alpha: 1.0)),
            .SelectionIndicatorBottomOffset(6),
            .SelectionIndicatorHeight(2.0),
            .SelectedMenuItemLabelColor(UIColor.whiteColor()),
            .UnselectedMenuItemLabelColor(UIColor(white:1.0, alpha: 0.5)),
            .MenuItemFont(UIFont.boldSystemFontOfSize(14.0)),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemTitleTopOffset(30.0),
            .EnableHorizontalBounce(false),
            .ContentScrollEnable(false),
            .MenuItemWidthBasedOnTitleTextWidth(false),
            .UseItemIcons(itemIcons)
        ]
        
        // MARK: initialize page menu with custom parameters
        let deviceFrame = UIScreen.mainScreen().bounds
        pageMenu = PageMenu(viewControllers: controllerArray, frame:deviceFrame, pageMenuOptions: parameters)
        controller1.scrollView.delegate = pageMenu
        controller2.scrollView.delegate = pageMenu
        controller3.scrollView.delegate = pageMenu
        self.view.addSubview(pageMenu!.view)
    }
    
    var hamburgerMenuControl : HamburgerMenu!
    func setupHamburgerMenu()
    {
        //MARK: create hamburger menu
        //calculate positions
        let sw = UIScreen.mainScreen().bounds.width
        let sh = UIScreen.mainScreen().bounds.height
        let menuSize = CGSizeMake(50, 50)
        let itemsSize = CGSizeMake(75, 75)
        let firstLayerY = sh - 40; let secondLayerY = firstLayerY - 80
        let firstLayerBorderOffset: CGFloat = 40.0 //right & left icons border offsets
        let secondLayerBorderOffset: CGFloat = 54.0
        let flOffset = CGPointMake((sw - 2.0 * firstLayerBorderOffset)/3.0, 0.0)
        let slOffset = CGPointMake((sw - 2.0 * secondLayerBorderOffset)/3.0, 0.0)
        
        //first layer
        let menuc = CGPointMake(firstLayerBorderOffset, firstLayerY)
        let item1c = menuc.add(flOffset)
        let item2c = item1c.add(flOffset)
        let item3c = item2c.add(flOffset)
        
        //second layer
        let item4c = CGPointMake(secondLayerBorderOffset, secondLayerY)
        let item5c = item4c.add(slOffset)
        let item6c = item5c.add(slOffset)
        let item7c = item6c.add(slOffset)
        
        //create items
        hamburgerMenuControl = HamburgerMenu(center:menuc, size: menuSize, menuIconImageName:"hamburgerMenuIcon", backIconImageName:"hamburgerMenu_backIcon", backButtonPositionOffset:CGPointMake(-3.0, 0.0))
        hamburgerMenuControl.addEventsObserver(self)
        let item1 = HamburgerLabelItem(center: item1c, size: itemsSize, info: "18", title: "Connecting")
        let item2 = HamburgerLabelItem(center: item2c, size: itemsSize, info: "146", title: "Connections")
        let item3 = HamburgerRoundImageItem(center: item3c, size: itemsSize, iconImageName:"avatarSample")
        item3.showBadgeExclamationMark()
        let item4 = HamburgerIconWithTitleItem(center: item4c, size: itemsSize, iconImageName: "houseIcon", title: "Home")
        item4.isItemSelected = true
        let item5 = HamburgerIconWithTitleItem(center: item5c, size: itemsSize, iconImageName: "scopeIcon", title: "Search")
        let item6 = HamburgerIconWithTitleAndBadgeItem(center: item6c, size: itemsSize, iconImageName: "messageIcon", title: "Messages", badgeNumber:2)
        item6.showBadgeExclamationMark()
        let item7 = HamburgerIconWithTitleAndBadgeItem(center: item7c, size: itemsSize, iconImageName: "bellIcon", title: "Notifications", badgeNumber:30)
        let itemsArray : Array<HamburgerItem> = [item1, item2, item3, item4, item5, item6, item7]
        hamburgerMenuControl.showBadgeExclamationMark()
        
        hamburgerController = HamburgerViewController(baseVC: self, items: itemsArray, menu:hamburgerMenuControl);
        hamburgerController.onMenuDidOpen = { [unowned self] in self.actionMenuController.hide() }
        hamburgerController.onMenuDidClose = { [unowned self] in  self.actionMenuController.show() }
    }
    
    deinit
    {
        println("PagesViewController DEINIT")
        hamburgerMenuControl.removeEventsObserver(self)
    }
    
    func onBackButtonTapped(menu: HamburgerMenu)
    {
        hamburgerMenuControl.menuState = HamburgerMenuState.Close
    }
    
    func setupActionMenu()
    {
        //MARK: create action menu
        let hsw = UIScreen.mainScreen().bounds.width/2.0
        let sh = UIScreen.mainScreen().bounds.height
        let yoffset : CGFloat = 70.0
        let xoffset : CGFloat = 20.0
        let ioffset : CGPoint = CGPointMake(10, -60)
        
        let menuCenter = CGPointMake(hsw, sh - 40)
        let menu = ActionMenu(center: menuCenter, normalIconImageName:"actionMenuIcon", activeIconImageName:"cameraIcon", title: "Camera")
        { [unowned self] item in self.hamburgerMenuControl.menuState = HamburgerMenuState.Disable }
        
        let item1Pos = menuCenter.add(ioffset)
        let item2Pos = item1Pos.add(ioffset)
        let item3Pos = item2Pos.add(ioffset)
        
        let item1 = ActionMenuItem(center:item1Pos, iconImageName:"textIcon", title:"Text")
        { [unowned self] item in self.hamburgerMenuControl.menuState = HamburgerMenuState.Close }
        let item2 = ActionMenuItem(center:item2Pos, iconImageName:"soundCloudIcon", title:"SoundCloud")
        { [unowned self] item in self.hamburgerMenuControl.menuState = HamburgerMenuState.Open }
        let item3 = ActionMenuItem(center:item3Pos, iconImageName:"youtubeIcon", title:"Youtube")
        let popItems = [item1, item2, item3]
        
        
        actionMenuController = ActionMenuViewController(baseVC: self, menuItem: menu, popItems: popItems)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setupPageMenu()
        setupActionMenu()
        setupHamburgerMenu()
    }
    
    override func preferredStatusBarStyle()->UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent;
    }
}

