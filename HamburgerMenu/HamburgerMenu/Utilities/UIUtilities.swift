import Foundation
import UIKit

class UIUtilities
{
    class func getTopViewController() -> UIViewController?
    {
        var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
        if  let rc = topController
        {
            var presentedController = rc.presentedViewController
            while(presentedController != nil)
            {
                topController = presentedController
                presentedController = presentedController!.presentedViewController
            }
        }
        return topController;
    }
    
    class func captureApplicationScreen() -> UIImage?
    {
        var capturedScreenImage: UIImage?
        if let window = UIApplication.sharedApplication().keyWindow
        {
            let rect = window.bounds;
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
            if let context = UIGraphicsGetCurrentContext() {
                window.layer.renderInContext(context);
            }
            capturedScreenImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        return capturedScreenImage
    }
    
    @available(iOS, introduced=7.0)
    class func convertViewToImage(view: UIView) -> UIImage
    {
        let scale: CGFloat = UIScreen.mainScreen().scale;        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, scale);
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false);
        let capturedScreenImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return capturedScreenImage
    }
}
