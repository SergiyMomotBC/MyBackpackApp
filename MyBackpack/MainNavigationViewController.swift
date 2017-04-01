//
//  MainNavigationViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/31/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import SideMenu

class MainNavigationViewController: UINavigationController 
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 16)!]
        
        self.applyGradientToNavigationBar()
        self.setupSideMenu()
    }

    func applyGradientToNavigationBar() {
        let layer = CAGradientLayer()
        layer.frame = navigationBar.bounds
        layer.frame.size.height += 20
        layer.colors = [UIColor.black.cgColor, navigationBar.barTintColor!.cgColor]
        
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        navigationBar.setBackgroundImage(image, for: .default)
    }
    
    func setupSideMenu() {
        SideMenuManager.menuLeftNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "leftMenu") as? UISideMenuNavigationController
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuBlurEffectStyle = UIBlurEffectStyle.dark
        SideMenuManager.menuFadeStatusBar = false
    }
}
