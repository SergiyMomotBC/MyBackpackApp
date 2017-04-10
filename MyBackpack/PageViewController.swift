//
//  ViewController.swift
//  MyBackpack
//
//  Created by Sergiy Momot on 2/7/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import SideMenu

class PageViewController: UIPageViewController
{
    var menuController: MenuController!
    var navigationTabBar: NavigationTabBar!
    var searchController: SearchController!
    var orderedViewControllers: [UIViewController] = []
    var currentPageIndex: Int = 0
    
    @IBOutlet var menuView: UIStackView!
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.menuController = MenuController(withStackView: self.menuView, inViewController: self, withYOffset: NavigationTabBar.height)
        self.navigationTabBar = NavigationTabBar(frame: .zero, forViewController: self)
        self.searchController = SearchController(forViewController: self)
        
        self.delegate = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)   
        self.orderedViewControllers.append(storyboard.instantiateViewController(withIdentifier: "contentVC"))
        self.orderedViewControllers.append(storyboard.instantiateViewController(withIdentifier: "calendarVC"))
        self.orderedViewControllers.append(storyboard.instantiateViewController(withIdentifier: "settingsVC"))
            
        if let initialViewController = self.orderedViewControllers.first {
            self.setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
            self.navigationTabBar.selectTab(atIndex: 0)
        }
    }
    
    @IBAction func showSearch(_ sender: Any) {
        if menuController.isShowing {
            self.hideMenu()
        }
        searchController.presentSearchBar(withResultsShowingIn: (orderedViewControllers[currentPageIndex] as! ContentTableViewController).tableView)
    }
    
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        if !self.menuController.isShowing {
            presentMenu()
        } else {
            hideMenu()
        }
    }
    
    @IBAction func sideMenuTapped(_ sender: Any) {
        self.present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func newContentTapped(_ sender: UIButton) {
        let newContentVC = NewContentViewController(forContentType: ContentType(rawValue: sender.tag)!)
        self.present(newContentVC, animated: true, completion: nil)
        self.hideMenu()
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
            self.searchController.hideSearchBar()
        }
    }
}    

extension PageViewController : UIPageViewControllerDelegate
{
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
