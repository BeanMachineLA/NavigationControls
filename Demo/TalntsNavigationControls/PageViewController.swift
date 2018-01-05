import UIKit

class PageViewController: UIViewController
{
    lazy var scrollView: UIScrollView =
    {
        let bounds: CGRect = UIScreen.mainScreen().bounds;
        let scrollContentHeight: CGFloat = bounds.height * 3.0
        let scroll = UIScrollView(frame: bounds)
        scroll.contentSize = CGSizeMake(bounds.width, scrollContentHeight)
        return scroll
    }()
    
    var initialBGColor: UIColor?
    convenience init( title: String, color: UIColor)
    {
        self.init()
        self.title = title
        initialBGColor = color
    }
    
    override func loadView()
    {    
        self.view = scrollView
        self.view.backgroundColor = initialBGColor
    }
}
