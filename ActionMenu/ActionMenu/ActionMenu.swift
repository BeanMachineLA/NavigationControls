//
//  ActionMenu.swift
//  TalntsNavigationControls
//
//  Created by Xorosho on 7/1/15.
//  Copyright (c) 2015 Xorosho. All rights reserved.
//

import Foundation
import UIKit

public class ActionMenu : ActionMenuItem
{
    public private(set) var isCanDoAction: Bool = false
    
    public var activeMenuIconImageView : UIImageView?
    public convenience init(center: CGPoint, normalIconImageName: String, activeIconImageName: String, title: String?, actionCallback: ItemTapCallback? = nil)
    {
        self.init(center:center, iconImageName:normalIconImageName, title:title, tapCallback:actionCallback)
        itemTitleLabel.alpha = 0.0
        
        //active icon image creation
        let image = UIImage(named:activeIconImageName)
        activeMenuIconImageView = UIImageView(image: image)
        activeMenuIconImageView?.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)
        activeMenuIconImageView?.hidden = true;
        if let iconView = activeMenuIconImageView { self.addSubview(iconView) }
    }
    
    public func activateActionState()
    {
        isCanDoAction = true
        iconImageView?.hidden = true
        activeMenuIconImageView?.hidden = false
        
        //add bounce animation 
        playBounceAnimationForView(activeMenuIconImageView)
        
        //show item label
        UIView.animateKeyframesWithDuration(0.1, delay: 0.2, options: [], animations: { () -> Void in
            self.itemTitleLabel.alpha = 1.0
        }, completion:nil)
    }
    
    public func deactivateActionState()
    {
        isCanDoAction = false
        iconImageView?.hidden = false
        activeMenuIconImageView?.hidden = true
        
        //add bounce animation
        playBounceAnimationForView(iconImageView)
        itemTitleLabel.alpha = 0.0
    }
    
    public override func appearWithAnimation(){}
    public override func disappearWithAnimation(){}
    
    private func playBounceAnimationForView(view: UIView?)
    {
        //add bounce animation
        let bounceAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath:"transform.scale")
        bounceAnimation.values = [0.95, 1.1, 0.95, 1.0];
        bounceAnimation.keyTimes = [0.0, 0.2, 0.75, 1.0];
        bounceAnimation.duration = 0.2;
        view?.layer.addAnimation(bounceAnimation, forKey:"bounce");
    }
    
    public override func playItemTappedAnimation(callback: ()->Void)
    {
        if isCanDoAction { super.playItemTappedAnimation(callback) }
    }

}