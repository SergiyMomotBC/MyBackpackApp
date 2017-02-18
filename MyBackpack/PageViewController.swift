//
//  ViewController.swift
//  MyBackpack
//
//  Created by Sergiy Momot on 2/7/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController
{
    var menuController: MenuController!
    var navigationTabBar: NavigationTabBar!
    
    @IBOutlet var menuView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuController = MenuController(withStackView: self.menuView, inViewController: self, withYOffset: 40)
        self.navigationTabBar = NavigationTabBar(frame: .zero, forViewController: self)
    }
    
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        if !self.menuController.isShowing {
            self.menuController.show { success in
                let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(self.showMenu))
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
            }
        } else {
            self.menuController.hide { success in
                let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.showMenu))
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
            }
        }
    }
}
