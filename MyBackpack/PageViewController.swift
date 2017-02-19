//
//  ViewController.swift
//  MyBackpack
//
//  Created by Sergiy Momot on 2/7/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController{
    var menuController: MenuController!
    var navigationTabBar: NavigationTabBar!
    var orderedViewControllers: [UIViewController] = []
    var currentPageIndex: Int = 0
    
    @IBOutlet var menuView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.menuController = MenuController(withStackView: self.menuView, inViewController: self, withYOffset: NavigationTabBar.height)
        self.navigationTabBar = NavigationTabBar(frame: .zero, forViewController: self)
        
        self.dataSource = self
        self.delegate = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.orderedViewControllers.append(storyboard.instantiateViewController(withIdentifier: "contentVC"))
        self.orderedViewControllers.append(storyboard.instantiateViewController(withIdentifier: "calendarVC"))
        self.orderedViewControllers.append(storyboard.instantiateViewController(withIdentifier: "settingsVC"))
        
        if let initialViewController = self.orderedViewControllers.first {
            self.setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
            self.navigationTabBar.selectTab(atIndex: 0)
        }
        
        var frame = self.navigationController?.navigationBar.bounds
        frame?.size.height +=  CGFloat(20 + NavigationTabBar.height)
        
        let layer = CAGradientLayer.gradientLayer(forBounds: frame!, startColor: UIColor.black, endColor: (self.navigationController?.navigationBar.barTintColor)!)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.navigationController?.navigationBar.setBackgroundImage(image?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
    }
    
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        if !self.menuController.isShowing {
            presentMenu()
        } else {
            hideMenu()
        }
    }
    
    func hideMenu() {
        self.menuController.hide { success in
            let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.showMenu))
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
        }
    }
    
    func presentMenu() {
        self.menuController.show { success in
            let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(self.showMenu))
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
        }
    }
}


extension PageViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        return viewControllerIndex - 1 >= 0 ? self.orderedViewControllers[viewControllerIndex - 1] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        return viewControllerIndex + 1 < self.orderedViewControllers.count ? self.orderedViewControllers[viewControllerIndex + 1] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let index = self.orderedViewControllers.index(of: (self.viewControllers?.first)!) {
                self.currentPageIndex = index
                self.navigationTabBar.selectTab(atIndex: self.currentPageIndex)
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if self.menuController.isShowing {
            self.menuController.hide(completion: { (success) in
                let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.showMenu))
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
            })
        }
    }
}
