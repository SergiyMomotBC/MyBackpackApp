//
//  ViewController.swift
//  MyBackpack
//
//  Created by Sergiy Momot on 2/7/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import SideMenu

protocol Updatable {
    func update()
}

class PageViewController: UIPageViewController, ClassObserver
{
    static let savedPageIndexKey = "savedPageIndexKey" 
    
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
        
        if let buttons = self.navigationController?.navigationBar.topItem?.rightBarButtonItems {
            buttons.forEach { $0.isEnabled = SideMenuViewController.currentClass != nil }
        }
        
        self.navigationController?.navigationBar.topItem?.title = SideMenuViewController.currentClass?.name ?? "No classes"
        
        SideMenuViewController.subscriber = self
        
        self.menuController = MenuController(withStackView: self.menuView, inViewController: self, withYOffset: NavigationTabBar.height)
        self.navigationTabBar = NavigationTabBar(frame: .zero, forViewController: self)
        self.searchController = SearchController(forViewController: self)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)   
        self.orderedViewControllers.append(storyboard.instantiateViewController(withIdentifier: "contentVC"))
        self.orderedViewControllers.append(storyboard.instantiateViewController(withIdentifier: "calendarVC"))
           
        if UserDefaults.standard.object(forKey: PageViewController.savedPageIndexKey) != nil {
            currentPageIndex = UserDefaults.standard.integer(forKey: PageViewController.savedPageIndexKey)
            self.setViewControllers([orderedViewControllers[currentPageIndex]], direction: .forward, animated: true, completion: nil)
            self.navigationTabBar.selectTab(atIndex: currentPageIndex)
        } else {
            self.setViewControllers([orderedViewControllers[0]], direction: .forward, animated: true, completion: nil)
            self.navigationTabBar.selectTab(atIndex: 0)
        }
    }
    
    var currentSearchableViewController: Searchable? {
        return orderedViewControllers[currentPageIndex] as? Searchable
    }
    
    @IBAction func showSearch(_ sender: Any) {
        if menuController.isShowing {
            self.hideMenu()
        }
        searchController.presentSearchBar()
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
        defer {
            self.hideMenu()
        }
        
        func displayPopUp(message: String) {
            let popup = PopUp()
            popup.addButton("Go to Settings", action: { 
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            popup.displayError(message: message, closeButtonTitle: "Close")
        }
        
        let type = ContentType(rawValue: sender.tag)!
        
        if (type == .Picture || type == .Video) { 
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            
            if status == .denied {
                displayPopUp(message: "Please enable the camera access in Settings app in order to take pictures and record videos.")
                return
            } else if status == .notDetermined {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { granted in
                    if granted {
                        let newContentVC = NewContentViewController(forContentType: type)
                        self.present(newContentVC, animated: true, completion: nil)
                    }
                })
                
                return 
            }
        } else if type == .Audio {
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
            
            if status == .denied {
                displayPopUp(message: "Please enable the microphone access in Settings app in order to record audio.")
                return
            } else if status == .notDetermined {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { granted in
                    if granted {
                        let newContentVC = NewContentViewController(forContentType: type)
                        self.present(newContentVC, animated: true, completion: nil)
                    }
                })
                
                return
            }
        } 
        
        let newContentVC = NewContentViewController(forContentType: type)
        self.present(newContentVC, animated: true, completion: nil)
    }
    
    @IBAction func newReminderTapped(_ sender: UIButton) {
        let newReminderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newReminderVC") as! NewReminderViewController
        newReminderVC.reminderType = ReminderType(rawValue: sender.tag)
        self.present(newReminderVC, animated: true, completion: nil)
        self.hideMenu()
    }
    
    func hideMenu() {
        self.menuController.hide { success in
            let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.showMenu))
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
        }
    }
    
    func presentMenu() {
        self.searchController.hideSearchBar()
        self.menuController.show { success in
            let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(self.showMenu))
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
        }
    }
    
    func classDidChange() {
        if menuController.isShowing {
            hideMenu()
        }
        
        if searchController.isActive {
            searchController.hideSearchBar()
        }
        
        self.navigationController?.navigationBar.topItem?.title = SideMenuViewController.currentClass?.name ?? "No classes"
        
        if let buttons = self.navigationController?.navigationBar.topItem?.rightBarButtonItems {
            buttons.forEach { $0.isEnabled = SideMenuViewController.currentClass != nil }
        }
        
        if let contentVC = orderedViewControllers[currentPageIndex] as? ContentTableViewController {
            contentVC.loadData(animated: true)
        } else if let remindersVC = orderedViewControllers[currentPageIndex] as? RemindersViewController {
            remindersVC.loadData(animated: true)
        }
    }
}    
