//
//  ActionMenu.swift
//  TalntsNavigationControls
//
//  Created by Xorosho on 7/1/15.
//  Copyright (c) 2015 Xorosho. All rights reserved.
//

import Foundation
import UIKit

public class ActionMenuViewController: UIViewController
{
    public var onMenuDidOpen:(()->Void)?
    public var onMenuDidClose:(()->Void)?
    
    public var isMenuOpen: Bool = false
    
    public var menuItem: ActionMenu!
    public var popItems: [ActionMenuItem]!
    public var backgroundView: UIView!
    public weak var baseVC : UIViewController?
    
    
    public var isHidden : Bool = false {
        didSet
        {
            menuItem.hidden = isHidden
            self.view.hidden = isHidden
        }
    }
    
    public convenience init(baseVC: UIViewController, menuItem:ActionMenu, popItems: [ActionMenuItem])
    {
        self.init()
        //base initialization
        self.baseVC = baseVC
        baseVC.addChildViewController(self)
        baseVC.view.addSubview(self.view)
        
        //create swallower view
        backgroundView = self.createSwallowView()
        backgroundView.alpha = 0.0
        self.view.addSubview(backgroundView)
        
        //setup menu item
        self.menuItem = menuItem
        menuItem.center = menuItem.initialPosition
        menuItem.addTarget(self, action: "onMenuItemTapped:", forControlEvents: .TouchUpInside)
        baseVC.view.addSubview(menuItem)
        
        //setup pop items
        self.setupPopItems(popItems)
    }
    
    override public func loadView()
    {
        let screenBounds = UIScreen.mainScreen().bounds
        let view = UIView(frame: screenBounds)
        self.view = view
        self.view.userInteractionEnabled = false
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "closeMenu"))
    }
    
    private func setupPopItems(items: [ActionMenuItem])
    {
        popItems = items
        let homePosition = self.menuItem.initialPosition
        var tagCounter: Int = 0
        let _ = popItems.map {
            (item: ActionMenuItem) -> () in
            self.view.addSubview(item)
            item.tag = tagCounter
            item.center = homePosition
            item.homePosition = homePosition
            item.deactivate()
            item.addTarget(self, action: "onPopItemTapped:", forControlEvents: .TouchUpInside)
            tagCounter++
        }
    }
    
    public func onMenuItemTapped(menu: ActionMenu)
    {
        if menu.isCanDoAction
        {
            menu.playItemTappedAnimation({ [weak self] in self?.closeMenu() })
        }
        else
        {
            menu.activateActionState()
            openMenu()
        }
    }
    
    public func onPopItemTapped(item: ActionMenuItem)
    {
        item.playItemTappedAnimation{ [weak self] in self?.closeMenu() }
    }
    
    public func openMenu()
    {
        isMenuOpen = true
        baseVC?.view.bringSubviewToFront(self.view)
        baseVC?.view.bringSubviewToFront(menuItem)
        showSwallowerView()
        self.view.userInteractionEnabled = true
        let _ = popItems.map{item in item.appearWithAnimation()}
        
        if let callback = onMenuDidOpen { callback() }
    }
    
    public func closeMenu()
    {
        isMenuOpen = false
        hideSwallowerView()
        self.view.userInteractionEnabled = false
        let _ = popItems.map{item in item.disappearWithAnimation()}
        menuItem.activate()
        menuItem.deactivateActionState()
        
        if let callback = onMenuDidClose { callback() }
    }
    
    private func showSwallowerView()
    {
        backgroundView.alpha = 0.0
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.backgroundView.alpha = 1.0
        })
    }
    
    private func hideSwallowerView()
    {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.backgroundView.alpha = 0.0
        })
    }
    
    private func createSwallowView() -> UIView
    {
        let screenRect = UIScreen.mainScreen().bounds
        let swallowView = UIView(frame: screenRect)
        let blackoutView = UIView(frame: screenRect)
        blackoutView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth];
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 26.0/255.0, alpha: 0.5).CGColor, UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 26.0/255.0, alpha: 1.0).CGColor]
        blackoutView.layer.insertSublayer(gradient, atIndex: 0)
        
        swallowView.addSubview(blackoutView)
        return swallowView;
    }
}