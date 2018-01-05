import UIKit

@objc public protocol PageMenuDelegate
{
    @objc optional func willMoveToPage(_ controller: UIViewController, index: Int)
    @objc optional func didMoveToPage(_ controller: UIViewController, index: Int)
}

public enum PageMenuOption
{
    case menuItemTitleTopOffset(CGFloat)
    case selectionIndicatorWidthPercent(Int)
    case selectionIndicatorBottomOffset(CGFloat)
    case selectionIndicatorHeight(CGFloat)
    case scrollMenuBackgroundColor(UIColor)
    case translucentScrollMenu(Bool)
    case viewBackgroundColor(UIColor)
    case addBottomMenuHairline(Bool)
    case bottomMenuHairlineColor(UIColor)
    case bottomMenuHairlineBottomOffset(CGFloat)
    case bottomMenuHairlineHeight(CGFloat)
    case selectionIndicatorColor(UIColor)
    case menuMargin(CGFloat)
    case menuHeight(CGFloat)
    case selectedMenuItemLabelColor(UIColor)
    case unselectedMenuItemLabelColor(UIColor)
    case useMenuLikeSegmentedControl(Bool)
    case menuItemFont(UIFont)
    case menuItemWidth(CGFloat)
    case enableHorizontalBounce(Bool)
    case menuItemWidthBasedOnTitleTextWidth(Bool)
    case scrollAnimationDurationOnMenuItemTap(Int)
    case centerMenuItems(Bool)
    case contentScrollEnable(Bool)
    case useItemIcons([(selectedIcon: UIImage, unselectedIcon: UIImage)])
    case minMenuHeightOnScroll(CGFloat)
    case pagesPreloadingOffset(Int)
}

private extension Array {
    subscript (safe index: Int) -> Element? {
        return indices.contains(index) ? self[index]: nil
    }
}

func round(_ rect: CGRect) -> CGRect {
    return CGRect(x: round(rect.origin.x), y: round(rect.origin.y), width: round(rect.width), height: round(rect.height))
}

open class MenuScrollView: UIScrollView {
    
    open let translucent: Bool
    fileprivate var blurView: UIVisualEffectView?
    init(frame: CGRect, translucent: Bool, backgroundColor: UIColor) {
        self.translucent = translucent
        super.init(frame: frame)
        
        if translucent {
            self.backgroundColor = backgroundColor
            let visualEffect = UIBlurEffect(style: .dark)
            blurView = UIVisualEffectView(effect: visualEffect)
            blurView!.frame = self.bounds
            blurView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(blurView!)
        } else {
            self.backgroundColor = backgroundColor
        }
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

open class PageMenu: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate
{
    // MARK: - Properties
    open var menuScrollView: MenuScrollView!
    open let controllerScrollView = UIScrollView()
    open let controllersArray: [UIViewController]
    open private(set) var menuItems: [PageMenuItem] = []
    var menuItemWidths: [CGFloat] = []
    
    open fileprivate(set) var menuHeight: CGFloat = 34.0
    open fileprivate(set) var menuMargin: CGFloat = 15.0
    open fileprivate(set) var menuItemWidth: CGFloat = 111.0
    open fileprivate(set) var selectionIndicatorHeight: CGFloat = 3.0
    open fileprivate(set) var selectionIndicatorWidthPercent: Int = 100
    open fileprivate(set) var menuItemTitleTopOffset: CGFloat = 0.0
    open fileprivate(set) var minMenuHeightOnScroll: CGFloat = 0.0
    open fileprivate(set) var pagesPreloadingOffset: Int = 1
    open fileprivate(set) var selectionIndicatorBottomOffset: CGFloat = 0.0
    open fileprivate(set) var scrollAnimationDurationOnMenuItemTap: Int = 500 // Millisecons
    open fileprivate(set) var selectionIndicatorColor: UIColor = UIColor.white
    open fileprivate(set) var selectedMenuItemLabelColor: UIColor = UIColor.white
    open fileprivate(set) var unselectedMenuItemLabelColor: UIColor = UIColor.lightGray
    open fileprivate(set) var scrollMenuBackgroundColor: UIColor = UIColor.black
    open fileprivate(set) var viewBackgroundColor: UIColor = UIColor.white
    open fileprivate(set) var bottomMenuHairlineColor: UIColor = UIColor.white
    open fileprivate(set) var menuItemFont: UIFont = UIFont.systemFont(ofSize: 15.0)
    open fileprivate(set) var menuItemWidthBasedOnTitleTextWidth: Bool = false
    open fileprivate(set) var useMenuLikeSegmentedControl: Bool = false
    open fileprivate(set) var centerMenuItems: Bool = false
    open fileprivate(set) var enableHorizontalBounce: Bool = true
    open fileprivate(set) var contentScrollEnable: Bool = true
    open fileprivate(set) var translucentScrollMenu: Bool = false
    open fileprivate(set) var addBottomMenuHairline : Bool = false
    open fileprivate(set) var bottomMenuHairlineBottomOffset: CGFloat = 0.0
    open fileprivate(set) var bottomMenuHairlineHeight: CGFloat = 0.0
    
    var totalMenuItemWidthIfDifferentWidths: CGFloat = 0.0
    var startingMenuMargin: CGFloat = 0.0
    
    var selectionIndicatorView: UIView = UIView()
    
    open var currentPageIndex: Int = -1 {
        willSet {
            if newValue != currentPageIndex {
                viewControllersLifeCycle(oldIndex: currentPageIndex, newIndex: newValue)
            }
        }
    }
    
    var useItemIcons: Bool = false
    var itemsIcons: [(selectedIcon: UIImage, unselectedIcon: UIImage)]?
    var currentOrientationIsPortrait: Bool = true
    var pageIndexForOrientationChange: Int = 0
    var didLayoutSubviewsAfterRotation: Bool = false
    var didTapMenuItemToScroll: Bool = false
    
    
    open weak var delegate: PageMenuDelegate?
    
    fileprivate let viewWidth: CGFloat
    fileprivate let viewHeight: CGFloat
    fileprivate var statusBarOrientation = UIApplication.shared.statusBarOrientation
    
    required public init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - View life cycle
    public init(viewControllers: [UIViewController], startIndex:Int, frame: CGRect, pageMenuOptions: [PageMenuOption]?)
    {
        viewWidth = frame.width
        viewHeight = frame.height
        
        controllersArray = viewControllers
        super.init(nibName: nil, bundle: nil)
        
        self.view.frame = frame
        if let options = pageMenuOptions
        {
            for option in options
            {
                switch (option)
                {
                case let .menuItemTitleTopOffset(value):
                    menuItemTitleTopOffset = value
                case let .selectionIndicatorWidthPercent(value):
                    selectionIndicatorWidthPercent = value
                case let .selectionIndicatorBottomOffset(value):
                    selectionIndicatorBottomOffset = value
                case let .selectionIndicatorHeight(value):
                    selectionIndicatorHeight = value
                case let .scrollMenuBackgroundColor(value):
                    scrollMenuBackgroundColor = value
                case let .viewBackgroundColor(value):
                    viewBackgroundColor = value
                case let .bottomMenuHairlineColor(value):
                    bottomMenuHairlineColor = value
                case let .addBottomMenuHairline(value):
                    addBottomMenuHairline = value
                case let .selectionIndicatorColor(value):
                    selectionIndicatorColor = value
                case let .menuMargin(value):
                    menuMargin = value
                case let .menuHeight(value):
                    menuHeight = value
                case let .selectedMenuItemLabelColor(value):
                    selectedMenuItemLabelColor = value
                case let .unselectedMenuItemLabelColor(value):
                    unselectedMenuItemLabelColor = value
                case let .useMenuLikeSegmentedControl(value):
                    useMenuLikeSegmentedControl = value
                case let .menuItemFont(value):
                    menuItemFont = value
                case let .menuItemWidth(value):
                    menuItemWidth = value
                case let .enableHorizontalBounce(value):
                    enableHorizontalBounce = value
                case let .menuItemWidthBasedOnTitleTextWidth(value):
                    menuItemWidthBasedOnTitleTextWidth = value
                case let .scrollAnimationDurationOnMenuItemTap(value):
                    scrollAnimationDurationOnMenuItemTap = value
                case let .centerMenuItems(value):
                    centerMenuItems = value
                case let .contentScrollEnable(value):
                    contentScrollEnable = value
                case let .useItemIcons(value):
                    useItemIcons = true
                    itemsIcons = value
                case let .minMenuHeightOnScroll(value):
                    if menuHeight <= value { print("PageMenu::init. Can't set MinMenuHeightOnScroll. Value must be less than menu height") }
                    else { minMenuHeightOnScroll = min(menuHeight, value) }
                case let .pagesPreloadingOffset(value):
                    pagesPreloadingOffset = value
                case let .translucentScrollMenu(value):
                    translucentScrollMenu = value
                case let .bottomMenuHairlineBottomOffset(value):
                    bottomMenuHairlineBottomOffset = value
                case let .bottomMenuHairlineHeight(value):
                    bottomMenuHairlineHeight = value
                }
            }
        }
        
        setUpUserInterface()
        configureUserInterface(startIndex)
    }
    
    deinit {
        controllerScrollView.delegate = nil
        menuScrollView.delegate = nil
    }
    
    fileprivate func setUpUserInterface()
    {
        // Set background color behind scroll views and for menu scroll view
        self.view.backgroundColor = viewBackgroundColor
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        // Set up controller scroll view
        let controllersScrollTopOffset = translucentScrollMenu ? 0 :  menuHeight
        let controllersScrollHeight = translucentScrollMenu ? viewHeight : viewHeight - menuHeight
        controllerScrollView.isPagingEnabled = true
        controllerScrollView.alwaysBounceHorizontal = enableHorizontalBounce
        controllerScrollView.bounces = enableHorizontalBounce
        controllerScrollView.frame = CGRect(x: 0.0, y: controllersScrollTopOffset, width: viewWidth, height: controllersScrollHeight)
        controllerScrollView.showsHorizontalScrollIndicator = false
        controllerScrollView.showsVerticalScrollIndicator = false
        controllerScrollView.isScrollEnabled = contentScrollEnable
        self.view.addSubview(controllerScrollView)
        
        // Add hairline to menu scroll view
        if addBottomMenuHairline {
            let menuBottomHairlineFrame = CGRect(x: 0, y: menuHeight - bottomMenuHairlineHeight + bottomMenuHairlineBottomOffset, width: viewWidth, height: bottomMenuHairlineHeight)
            let menuBottomHairline: UIView = UIView(frame: menuBottomHairlineFrame)
            menuBottomHairline.autoresizingMask = [.flexibleWidth]
            menuBottomHairline.backgroundColor = bottomMenuHairlineColor
            
            self.view.addSubview(menuBottomHairline)
        }
        
        // Set up menu scroll
        menuScrollView = MenuScrollView(frame: CGRect(x: 0.0, y: 0.0, width: viewWidth, height: menuHeight), translucent: translucentScrollMenu, backgroundColor: scrollMenuBackgroundColor)
        menuScrollView.showsHorizontalScrollIndicator = false
        menuScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(menuScrollView)
    }
    
    fileprivate func configureUserInterface(_ startIndex: Int)
    {
        // Add tap gesture recognizer to controller scroll view to recognize menu item selection
        let menuItemTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PageMenu.handleMenuItemTap(_:)))
        menuItemTapGestureRecognizer.numberOfTapsRequired = 1
        menuItemTapGestureRecognizer.numberOfTouchesRequired = 1
        menuItemTapGestureRecognizer.delegate = self
        menuScrollView.addGestureRecognizer(menuItemTapGestureRecognizer)
        
        // Set delegate for controller scroll view
        controllerScrollView.delegate = self
        
        // When the user taps the status bar, the scroll view beneath the touch which is closest to the status bar will be scrolled to top,
        // but only if its `scrollsToTop` property is YES, its delegate does not return NO from `shouldScrollViewScrollToTop`, and it is not already at the top.
        // If more than one scroll view is found, none will be scrolled.
        // Disable scrollsToTop for menu and controller scroll views so that iOS finds scroll views within our pages on status bar tap gesture.
        menuScrollView.scrollsToTop = false
        controllerScrollView.scrollsToTop = false
        
        // Configure menu scroll view
        if useMenuLikeSegmentedControl
        {
            menuScrollView.isScrollEnabled = false
            menuScrollView.contentSize = CGSize(width: viewWidth, height: menuHeight)
            menuMargin = 0.0
        }
        else
        {
            menuScrollView.contentSize = CGSize(width: (menuItemWidth + menuMargin) * CGFloat(controllersArray.count) + menuMargin, height: menuHeight)
        }
        
        // Configure controller scroll view content size
        controllerScrollView.contentSize = CGSize(width: viewWidth * CGFloat(controllersArray.count), height: 0.0)
        
        for (index, controller) in controllersArray.enumerated()
        {
            // Set up menu item for menu scroll view
            var menuItemFrame: CGRect = CGRect()
            
            if useMenuLikeSegmentedControl
            {
                menuItemFrame = CGRect(x: viewWidth / CGFloat(controllersArray.count) * CGFloat(index), y: 0.0, width: CGFloat(viewWidth) / CGFloat(controllersArray.count), height: menuHeight)
                let controllerTitle: String? = controller.title
                let titleText: String = controllerTitle != nil ? controllerTitle!: "Menu \(Int(index) + 1)"
                let itemWidthRect: CGRect = (titleText as NSString).boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:menuItemFont], context: nil)
                menuItemWidth = CGFloat(viewWidth) / CGFloat(controllersArray.count)
                let indicatorWidths = menuItemWidthBasedOnTitleTextWidth ? itemWidthRect.width: menuItemWidth
                menuItemWidths.append(indicatorWidths)
            }
            else if menuItemWidthBasedOnTitleTextWidth {
                let controllerTitle: String? = controller.title
                
                let titleText: String = controllerTitle != nil ? controllerTitle!: "Menu \(Int(index) + 1)"
                
                let itemWidthRect: CGRect = (titleText as NSString).boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:menuItemFont], context: nil)
                
                menuItemWidth = itemWidthRect.width
                
                menuItemFrame = CGRect(x: totalMenuItemWidthIfDifferentWidths + menuMargin + (menuMargin * CGFloat(index)), y: 0.0, width: menuItemWidth, height: menuHeight)
                
                totalMenuItemWidthIfDifferentWidths += itemWidthRect.width
                menuItemWidths.append(itemWidthRect.width)
            }
            else
            {
                if centerMenuItems && index == 0
                {
                    startingMenuMargin = ((viewWidth - ((CGFloat(controllersArray.count) * menuItemWidth) + (CGFloat(controllersArray.count - 1) * menuMargin))) / 2.0) -  menuMargin
                    
                    if startingMenuMargin < 0.0 {
                        startingMenuMargin = 0.0
                    }
                    
                    menuItemFrame = CGRect(x: startingMenuMargin + menuMargin, y: 0.0, width: menuItemWidth, height: menuHeight)
                }
                else
                {
                    menuItemFrame = CGRect(x: menuItemWidth * CGFloat(index) + menuMargin * CGFloat(index + 1) + startingMenuMargin, y: 0.0, width: menuItemWidth, height: menuHeight)
                }
                menuItemWidths.append(menuItemWidth)
            }
            
            let roundedMenuItemFrame = round(menuItemFrame)
            let menuItemView: PageMenuItem = createMenuItem(controller, startIndex: startIndex, itemIndex: index, itemFrame: roundedMenuItemFrame)
            menuScrollView.addSubview(menuItemView)
            menuItems.append(menuItemView)
        }
        
        //Set new content size for menu scroll view if needed
        if menuItemWidthBasedOnTitleTextWidth
        {
            menuScrollView.contentSize = CGSize(width: (totalMenuItemWidthIfDifferentWidths + menuMargin) + CGFloat(controllersArray.count) * menuMargin, height: menuHeight)
        }
        
        // Configure selection indicator view
        var selectionIndicatorFrame: CGRect = CGRect()
        let selectionIndicatorY = menuHeight - selectionIndicatorHeight - selectionIndicatorBottomOffset
        let indicatorWidthRate = CGFloat(selectionIndicatorWidthPercent)/100.0
        var selectionIndicatorWidth: CGFloat = 100.0
        var selectionIndicatorX: CGFloat = 0.0
        
        if useMenuLikeSegmentedControl
        {
            let itemWidth = viewWidth / CGFloat(controllersArray.count)
            let indicatorWidth = menuItemWidths[0]
            selectionIndicatorWidth = indicatorWidth * indicatorWidthRate
            selectionIndicatorX = (itemWidth - selectionIndicatorWidth)/2.0
            selectionIndicatorFrame = CGRect(x: selectionIndicatorX, y: selectionIndicatorY, width: selectionIndicatorWidth, height: selectionIndicatorHeight)
        }
        else if menuItemWidthBasedOnTitleTextWidth
        {
            selectionIndicatorWidth = menuItemWidths[0] * indicatorWidthRate
            selectionIndicatorX = menuMargin + (menuItemWidths[0] - selectionIndicatorWidth)/2.0
            selectionIndicatorFrame = CGRect(x: selectionIndicatorX, y: selectionIndicatorY, width: selectionIndicatorWidth, height: selectionIndicatorHeight)
        } else
        {
            selectionIndicatorWidth = menuItemWidth * indicatorWidthRate
            if centerMenuItems
            {
                selectionIndicatorX = startingMenuMargin + menuMargin + (menuItemWidth - selectionIndicatorWidth)/2.0
                selectionIndicatorFrame = CGRect(x: selectionIndicatorX, y: selectionIndicatorY, width: selectionIndicatorWidth, height: selectionIndicatorHeight)
            } else
            {
                selectionIndicatorX = menuMargin + (menuItemWidth - selectionIndicatorWidth)/2.0
                selectionIndicatorFrame = CGRect(x: selectionIndicatorX, y: selectionIndicatorY, width: selectionIndicatorWidth, height: selectionIndicatorHeight)
            }
        }
        
        selectionIndicatorView = UIView(frame: selectionIndicatorFrame)
        selectionIndicatorView.backgroundColor = selectionIndicatorColor
        menuScrollView.addSubview(selectionIndicatorView)
        
        _ = moveToPage(startIndex, animated: false)
    }
    
    fileprivate func createMenuItem(_ controller: UIViewController, startIndex: Int, itemIndex: Int, itemFrame: CGRect) -> PageMenuItem
    {
        if useItemIcons
        {
            let icons = itemsIcons![ itemIndex ]
            let menuItemView = PageMenuItemIcon(frame:itemFrame, selectedIcon: icons.selectedIcon, unselectedIcon: icons.unselectedIcon, topOffset:menuItemTitleTopOffset)
            menuItemView.isSelected = startIndex == itemIndex
            return menuItemView
        }
        else
        {
            let title: String  = controller.title ?? "Menu \(itemIndex + 1)"
            let menuItemView: PageMenuItemLabel = PageMenuItemLabel(frame: itemFrame, topOffset: menuItemTitleTopOffset, title: title, selectedColor: selectedMenuItemLabelColor, unselectedColor: unselectedMenuItemLabelColor)
            menuItemView.titleLabel.font = menuItemFont
            menuItemView.isSelected = startIndex == itemIndex
            return menuItemView
        }
    }
    
    fileprivate func viewControllersLifeCycle(oldIndex: Int, newIndex: Int) {
        let old = controllersArray[safe: oldIndex]
        let new = controllersArray[safe: newIndex]
        
        old?.viewWillDisappear(false)
        old?.viewDidDisappear(false)
        new?.viewWillAppear(false)
        new?.viewDidAppear(false)
    }
    
    // MARK: - Scroll view delegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let isControllerScrollView = scrollView.isEqual(controllerScrollView)
        let isMenuScrollView = scrollView.isEqual(menuScrollView)
        
        if !isControllerScrollView && !isMenuScrollView
        {
            self.containerScrollViewDidScroll(scrollView)
            return
        }
        
        if !didLayoutSubviewsAfterRotation {
            if isControllerScrollView {
                let contentOffsetX = controllerScrollView.contentOffset.x
                if contentOffsetX >= 0.0 && contentOffsetX <= (CGFloat(controllersArray.count - 1) * viewWidth) {
                    
                    // Calculate ratio between scroll views
                    if menuScrollView.contentSize.width > viewWidth {
                        let ratio = (menuScrollView.contentSize.width - viewWidth) / (controllerScrollView.contentSize.width - viewWidth)
                        var offset: CGPoint = menuScrollView.contentOffset
                        offset.x = controllerScrollView.contentOffset.x * ratio
                        menuScrollView.setContentOffset(offset, animated: false)
                    }
                    
                    // Calculate current page
                    let page = Int((controllerScrollView.contentOffset.x/viewWidth) + 0.5)
                    
                    // Update page if changed
                    if page != currentPageIndex
                    {
                        currentPageIndex = page
                        
                        configurePages(currentPageIndex, offset: pagesPreloadingOffset)
                        snapMenuViewToTop()
                        
                        moveSelectionIndicator(page)
                    }
                }
                else
                {
                    if menuScrollView.contentSize.width > viewWidth {
                        let ratio = (menuScrollView.contentSize.width - viewWidth) / (controllerScrollView.contentSize.width - viewWidth)
                        var offset: CGPoint = menuScrollView.contentOffset
                        offset.x = controllerScrollView.contentOffset.x * ratio
                        menuScrollView.setContentOffset(offset, animated: false)
                    }
                }
            }
        }
        else
        {
            didLayoutSubviewsAfterRotation = false
            moveSelectionIndicator(currentPageIndex)
        }
    }
    
    open func snapPageBaseOnScrollViewOffset()
    {
        // Calculate current page
        let width: CGFloat = controllerScrollView.frame.size.width;
        let page: Int = Int((controllerScrollView.contentOffset.x + (0.5 * width)) / width)
        
        // Update page if changed
        if page != currentPageIndex
        {
            currentPageIndex = page
            
            configurePages(currentPageIndex, offset: pagesPreloadingOffset)
            snapMenuViewToTop()
            
            moveSelectionIndicator(page)
            _ = moveToPage(currentPageIndex, animated: true)
        }
    }
    
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        if !scrollView.isEqual(controllerScrollView) && !scrollView.isEqual(menuScrollView)
        {
            self.containerScrollViewDidEndDecelerating(scrollView)
            return
        }
        
        if scrollView.isEqual(controllerScrollView)
        {
            // Call didMoveToPage delegate function
            let currentController = controllersArray[currentPageIndex]
            delegate?.didMoveToPage?(currentController, index: currentPageIndex)
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if !scrollView.isEqual(controllerScrollView) && !scrollView.isEqual(menuScrollView)
        {
            self.containerScrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
            return
        }
    }
    
    // MARK: - Handle Selection Indicator
    func moveSelectionIndicator(_ pageIndex: Int, animated: Bool = true)
    {
        if pageIndex >= 0 && pageIndex < controllersArray.count
        {
            for (index, item) in menuItems.enumerated() {
                item.isSelected = index == currentPageIndex
            }
            
            let selectionIndicatorFrame: CGRect = self.selectionIndicatorView.frame
            var selectionIndicatorWidth: CGFloat = selectionIndicatorFrame.width
            var selectionIndicatorX: CGFloat = 0.0
            
            if self.useMenuLikeSegmentedControl {
                selectionIndicatorX = CGFloat(pageIndex) * (self.viewWidth / CGFloat(self.controllersArray.count))
                let menuItemWidth = self.viewWidth / CGFloat(self.controllersArray.count)
                selectionIndicatorWidth = self.menuItemWidths[pageIndex]
                selectionIndicatorX += (menuItemWidth - selectionIndicatorWidth)/2.0
            } else if self.menuItemWidthBasedOnTitleTextWidth {
                selectionIndicatorWidth = self.menuItemWidths[pageIndex]
                selectionIndicatorX += self.menuMargin
                
                if pageIndex > 0 {
                    for i in 0...(pageIndex - 1) {
                        selectionIndicatorX += (self.menuMargin + self.menuItemWidths[i])
                    }
                }
            } else {
                selectionIndicatorWidth = self.menuItemWidths[pageIndex]
                if self.centerMenuItems && pageIndex == 0 {
                    selectionIndicatorX = self.startingMenuMargin + self.menuMargin
                } else {
                    selectionIndicatorX = self.menuItemWidth * CGFloat(pageIndex) + self.menuMargin * CGFloat(pageIndex + 1) + self.startingMenuMargin
                }
            }
            
            let selectionIndicatorWidthRate = CGFloat(selectionIndicatorWidthPercent)/100.0
            let indicatorWidth = selectionIndicatorWidth * selectionIndicatorWidthRate;
            let indicatorX = selectionIndicatorX + (selectionIndicatorWidth - indicatorWidth)/2.0
            let indicatorFrame = CGRect(x: indicatorX, y: selectionIndicatorFrame.origin.y, width: indicatorWidth, height: selectionIndicatorFrame.height)
            
            if animated {
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    self.selectionIndicatorView.frame = indicatorFrame
                })
            } else {
                selectionIndicatorView.frame = indicatorFrame
            }
            
        }
    }
    
    
    // MARK: - Tap gesture recognizer selector
    
    func handleMenuItemTap(_ gestureRecognizer: UITapGestureRecognizer)
    {
        let tappedPoint: CGPoint = gestureRecognizer.location(in: menuScrollView)
        
        if tappedPoint.y < menuScrollView.frame.height {
            
            // Calculate tapped page
            var itemIndex: Int = 0
            
            if useMenuLikeSegmentedControl {
                itemIndex = Int(tappedPoint.x / (viewWidth / CGFloat(controllersArray.count)))
            } else if menuItemWidthBasedOnTitleTextWidth {
                // Base case being first item
                var menuItemLeftBound: CGFloat = 0.0
                var menuItemRightBound: CGFloat = menuItemWidths[0] + menuMargin + (menuMargin / 2)
                
                if !(tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                    for i in 1...controllersArray.count - 1 {
                        menuItemLeftBound = menuItemRightBound + 1.0
                        menuItemRightBound = menuItemLeftBound + menuItemWidths[i] + menuMargin
                        
                        if tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound {
                            itemIndex = i
                            break
                        }
                    }
                }
            }
            else
            {
                let rawItemIndex: CGFloat = ((tappedPoint.x - startingMenuMargin) - menuMargin / 2) / (menuMargin + menuItemWidth)
                
                // Prevent moving to first item when tapping left to first item
                if rawItemIndex < 0 {
                    itemIndex = -1
                } else {
                    itemIndex = Int(rawItemIndex)
                }
            }
            
            if itemIndex >= 0 && itemIndex < controllersArray.count
            {
                // Update page if changed
                if itemIndex != currentPageIndex {
                    currentPageIndex = itemIndex
                    didTapMenuItemToScroll = true
                    
                    configurePages(currentPageIndex, offset: pagesPreloadingOffset)
                    moveSelectionIndicator(currentPageIndex)
                }
                
                
                // Move controller scroll view when tapping menu item
                let duration: Double = Double(scrollAnimationDurationOnMenuItemTap) / Double(1000)
                
                UIView.animate(withDuration: duration, animations: { () -> Void in
                    let xOffset: CGFloat = CGFloat(itemIndex) * self.controllerScrollView.frame.width
                    self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
                    }, completion: { finished in
                        let newVC = self.controllersArray[itemIndex]
                        self.delegate?.didMoveToPage?(newVC, index: itemIndex)
                    }
                )
            }
        }
    }
    
    
    // MARK: - Remove/Add Page
    fileprivate func configurePages(_ index: Int, offset: Int) {
        for i in (0..<controllersArray.count) {
            if i >= index - offset && i <= index + offset {
                addController(i)
            } else {
                removeController(i)
            }
        }
    }
    
    fileprivate func addController(_ index: Int){
        guard index >= 0 && index < controllersArray.count else { return }
        
        let newVC = controllersArray[index]
        delegate?.willMoveToPage?(newVC, index: index)
        if newVC.parent == nil
        {
            newVC.willMove(toParentViewController: self)
            newVC.view.frame = CGRect(x: viewWidth * CGFloat(index), y: 0.0, width: viewWidth, height: controllerScrollView.frame.size.height)
            self.addChildViewController(newVC)
            self.controllerScrollView.addSubview(newVC.view)
            newVC.didMove(toParentViewController: self)
        }
    }
    
    fileprivate func removeController(_ index: Int)
    {
        guard index >= 0 && index < controllersArray.count else { return }
        
        let oldVC = controllersArray[index]
        oldVC.willMove(toParentViewController: nil)
        oldVC.view.removeFromSuperview()
        oldVC.removeFromParentViewController()
        oldVC.didMove(toParentViewController: nil)
    }
    
    // MARK: - Orientation Change
    override open func viewDidLayoutSubviews()
    {
        // Configure controller scroll view content size
        statusBarOrientation = UIApplication.shared.statusBarOrientation
        controllerScrollView.contentSize = CGSize(width: viewWidth * CGFloat(controllersArray.count), height: 0.0)
        let oldCurrentOrientationIsPortrait: Bool = currentOrientationIsPortrait
        currentOrientationIsPortrait = statusBarOrientation.isPortrait
        
        if (oldCurrentOrientationIsPortrait && statusBarOrientation.isLandscape) || (!oldCurrentOrientationIsPortrait && statusBarOrientation.isPortrait) {
            didLayoutSubviewsAfterRotation = true
            
            //Resize menu items if using as segmented control
            if useMenuLikeSegmentedControl {
                menuScrollView.contentSize = CGSize(width: viewWidth, height: menuHeight)
                
                // Resize selectionIndicator bar
                let selectionIndicatorX: CGFloat = CGFloat(currentPageIndex) * (viewWidth / CGFloat(self.controllersArray.count))
                let selectionIndicatorWidth: CGFloat = viewWidth / CGFloat(self.controllersArray.count)
                selectionIndicatorView.frame =  CGRect(x: selectionIndicatorX, y: self.selectionIndicatorView.frame.origin.y, width: selectionIndicatorWidth, height: self.selectionIndicatorView.frame.height)
                
                // Resize menu items
                var index: Int = 0
                
                for item: PageMenuItem in menuItems as [PageMenuItem] {
                    let xOffset = round(viewWidth / CGFloat(controllersArray.count) * CGFloat(index))
                    let width = round(viewWidth / CGFloat(controllersArray.count))
                    item.frame = CGRect(x: xOffset, y: 0.0, width: width, height: menuHeight)
                    
                    index += 1
                }
            } else if centerMenuItems {
                startingMenuMargin = round(((viewWidth - ((CGFloat(controllersArray.count) * menuItemWidth) + (CGFloat(controllersArray.count - 1) * menuMargin))) / 2.0) -  menuMargin)
                
                if startingMenuMargin < 0.0 {
                    startingMenuMargin = 0.0
                }
                
                let selectionIndicatorX: CGFloat = self.menuItemWidth * CGFloat(currentPageIndex) + self.menuMargin * CGFloat(currentPageIndex + 1) + self.startingMenuMargin
                selectionIndicatorView.frame =  CGRect(x: selectionIndicatorX, y: self.selectionIndicatorView.frame.origin.y, width: self.selectionIndicatorView.frame.width, height: self.selectionIndicatorView.frame.height)
                
                // Recalculate frame for menu items if centered
                var index: Int = 0
                
                for item: PageMenuItem in menuItems as [PageMenuItem] {
                    if index == 0 {
                        item.frame = CGRect(x: startingMenuMargin + menuMargin, y: 0.0, width: menuItemWidth, height: menuHeight)
                    } else {
                        item.frame = CGRect(x: menuItemWidth * CGFloat(index) + menuMargin * CGFloat(index + 1) + startingMenuMargin, y: 0.0, width: menuItemWidth, height: menuHeight)
                    }
                    
                    index += 1
                }
            }
            
            for view: UIView in controllerScrollView.subviews {
                view.frame = CGRect(x: viewWidth * CGFloat(currentPageIndex), y: 0.0, width: controllerScrollView.frame.width, height: controllerScrollView.frame.height)
            }
            
            let xOffset: CGFloat = CGFloat(self.currentPageIndex) * controllerScrollView.frame.width
            controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: controllerScrollView.contentOffset.y), animated: false)
            
            let ratio: CGFloat = (menuScrollView.contentSize.width - viewWidth) / (controllerScrollView.contentSize.width - viewWidth)
            
            if menuScrollView.contentSize.width > viewWidth {
                var offset: CGPoint = menuScrollView.contentOffset
                offset.x = controllerScrollView.contentOffset.x * ratio
                menuScrollView.setContentOffset(offset, animated: false)
            }
        }
        
        // Hsoi 2015-02-05 - Running on iOS 7.1 complained: "'NSInternalInconsistencyException', reason: 'Auto Layout
        // still required after sending -viewDidLayoutSubviews to the view controller. ViewController's implementation
        // needs to send -layoutSubviews to the view to invoke auto layout.'"
        //
        // http://stackoverflow.com/questions/15490140/auto-layout-error
        //
        // Given the SO answer and caveats presented there, we'll call layoutIfNeeded() instead.
        self.view.layoutIfNeeded()
    }
    
    
    // MARK: - Move to page index
    /**
     Move to page at index
     param: index Index of the page to move to
     */
    open func moveToPage(_ index: Int, animated:Bool) -> Bool
    {
        if index >= 0 && index < controllersArray.count
        {
            // Update page if changed
            if index != currentPageIndex
            {
                currentPageIndex = index
                didTapMenuItemToScroll = true
                
                configurePages(currentPageIndex, offset: pagesPreloadingOffset)
                moveSelectionIndicator(currentPageIndex, animated: animated)
                
                snapMenuViewToTop()
            }
            
            if animated
            {
                // Move controller scroll view when tapping menu item
                let duration: Double = Double(scrollAnimationDurationOnMenuItemTap) / Double(1000)
                
                UIView.animate(withDuration: duration, animations: { () -> Void in
                    let xOffset: CGFloat = CGFloat(index) * self.controllerScrollView.frame.width
                    self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
                    }, completion:
                    {
                        finished in
                        let currentController = self.controllersArray[index]
                        self.delegate?.didMoveToPage?(currentController, index:index)
                })
            }
            else
            {
                let xOffset: CGFloat = CGFloat(index) * self.controllerScrollView.frame.width
                self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
                
                let currentController = self.controllersArray[index]
                self.delegate?.didMoveToPage?(currentController, index:index)
            }
            return true
        }
        return false
    }
    
    //MARK: containers scroll vies methods
    fileprivate var previousScrollOffsets = NSMapTable<UIScrollView, NSNumber>(keyOptions: NSMapTableWeakMemory, valueOptions: NSMapTableCopyIn)
    fileprivate func containerScrollViewDidScroll(_ scrollView: UIScrollView)
    {
        /* initial values */
        //menuScrollView.frame = CGRectMake(0.0, 0.0, viewWidth, menuHeight)
        //menuScrollView.contentSize = CGSizeMake(viewWidth, menuHeight)
        //controllerScrollView.frame = CGRectMake(0.0, menuHeight, viewWidth, viewHeight - menuHeight)
        
        let previousScrollViewYOffset = CGFloat(previousScrollOffsets.object(forKey: scrollView)?.floatValue ?? 0.0)
        
        var frame = menuScrollView.frame
        let scrollOffset = scrollView.contentOffset.y
        let scrollDiff = scrollOffset - previousScrollViewYOffset
        let scrollHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        if (scrollHeight >= scrollContentSizeHeight) { return }
        
        let scrolableHeight = menuHeight - minMenuHeightOnScroll
        let minY: CGFloat = -scrolableHeight
        let maxY: CGFloat = 0.0
        
        if scrollOffset <= -scrollView.contentInset.top
        {
            frame.origin.y = maxY
        }
        else if (scrollOffset + scrollHeight) >= scrollContentSizeHeight
        {
            frame.origin.y = minY
        }
        else
        {
            frame.origin.y = min(maxY, max(minY, frame.origin.y - scrollDiff))
        }
        
        menuScrollView.frame = frame
        if !translucentScrollMenu {
            let controllerScrollViewTop = frame.origin.y + menuScrollView.frame.height
            controllerScrollView.frame.origin.y = controllerScrollViewTop
            controllerScrollView.frame.size.height = viewHeight - controllerScrollViewTop
            for controller in controllersArray {
                controller.view.frame.size.height = controllerScrollView.frame.size.height
            }
        }
        let menuPercenrageHidden = max(scrolableHeight + 2.0 * frame.origin.y, 0.0)/scrolableHeight
        updateMenuItemsAlpha(menuPercenrageHidden)
        let offset = NSNumber(value: Float(scrollOffset))
        previousScrollOffsets.setObject(offset, forKey: scrollView)
    }
    
    fileprivate func snapMenuViewToTop()
    {
        animateMenuViewTo(0.0)
    }
    
    fileprivate func containerScrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        self.containerScrollStoppedScrolling()
    }
    
    fileprivate func containerScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if !decelerate { self.containerScrollStoppedScrolling() }
    }
    
    fileprivate func containerScrollStoppedScrolling()
    {
        let scrolableHeight = menuHeight - minMenuHeightOnScroll
        let minY: CGFloat = -scrolableHeight
        let maxY: CGFloat = 0.0
        
        let frame = menuScrollView.frame
        if frame.origin.y < -scrolableHeight/2.0
        {
            animateMenuViewTo(minY)
            updateMenuItemsAlpha(0.0)
        }
        else
        {
            animateMenuViewTo(maxY)
            updateMenuItemsAlpha(1.0)
        }
    }
    
    fileprivate func animateMenuViewTo(_ y:CGFloat)
    {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.menuScrollView.frame.origin.y = y
            y < 0 ? self.updateMenuItemsAlpha(0.0): self.updateMenuItemsAlpha(1.0)
            
            if !self.translucentScrollMenu {
                let controllerScrollViewTop = y + self.menuHeight
                self.controllerScrollView.frame.origin.y = controllerScrollViewTop
                self.controllerScrollView.frame.size.height = self.viewHeight - controllerScrollViewTop
                for controller in self.controllersArray {
                    controller.view.frame.size.height = self.controllerScrollView.frame.size.height
                }
            }
        })
    }
    
    fileprivate func updateMenuItemsAlpha(_ a:CGFloat)
    {
        selectionIndicatorView.alpha = a
        for menu in menuItems
        {
            menu.alpha = a
        }
    }
}

