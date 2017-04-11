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
        
        navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 17)!]

        SideMenuManager.menuLeftNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "leftMenu") as? UISideMenuNavigationController
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuBlurEffectStyle = UIBlurEffectStyle.dark
        SideMenuManager.menuFadeStatusBar = false
    }
}
