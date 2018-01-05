
import Foundation
import UIKit

enum SwallowViewType
{
    case Shadow
    case Blur
    case Gradient
}

class SwallowView
{
    class func generateSwallowView(type: SwallowViewType) -> UIView
    {
        let screenRect = UIScreen.mainScreen().bounds
        let swallowView: UIView
        switch type
        {
        case .Shadow:
            let blackoutView = UIView(frame: screenRect)
            blackoutView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth];
            blackoutView.backgroundColor = UIColor.blackColor()
            blackoutView.alpha = 0.9
            swallowView = blackoutView
        case .Blur:
            let captureImage = UIUtilities.captureApplicationScreen()
            let tintColor = UIColor(white: 0.2, alpha: 0.9)
            let blurSnapshotImage = captureImage?.applyBlurWithRadius(5.0, tintColor:tintColor, saturationDeltaFactor: 1.8, maskImage: nil)
            let imageView = UIImageView(frame: screenRect)
            imageView.image = blurSnapshotImage;
            swallowView = imageView
        case .Gradient:
            let blackoutView = UIView(frame: screenRect)
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = blackoutView.bounds
            gradient.colors = [UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 26.0/255.0, alpha: 0.5).CGColor, UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 26.0/255.0, alpha: 1.0).CGColor]
            blackoutView.layer.insertSublayer(gradient, atIndex: 0)
            swallowView = blackoutView
        }
        swallowView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth];
        return swallowView
    }
}
