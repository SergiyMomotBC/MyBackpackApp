//
//  SearchController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/31/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol Searchable
{
    func prepareForSearch(with controller: SearchController)
    func getFilterViewControllerToPresent() -> UIViewController
    func updateSearch(forText text: String)
    func endSearch(forced: Bool)
}

fileprivate class NoCancelButtonSearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setShowsCancelButton(false, animated: false)
    }
}

class SearchController: NSObject, UISearchBarDelegate, DZNEmptyDataSetSource
{
    var isActive = false
    
    lazy var searchBar: UISearchBar = {
        let searchBar = NoCancelButtonSearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search for content..."
        (searchBar.value(forKey: "searchField") as? UITextField)?.textColor = .white
        return searchBar
    }()
    
    lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar(frame: CGRect(x: self.parentViewController.view.bounds.width, 
                                                          y: 0.0, 
                                                          width: self.parentViewController.view.bounds.width, 
                                                          height: CGFloat(NavigationTabBar.height - 0.5)))
        navigationBar.layer.zPosition = CGFloat.greatestFiniteMagnitude - 1.0
        navigationBar.tintColor = .white
        navigationBar.barTintColor = self.parentViewController.navigationController?.navigationBar.barTintColor 
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        return navigationBar
    }()
    
    private var parentViewController: PageViewController
    
    init(forViewController vc: PageViewController) {
        parentViewController = vc
        
        super.init()
        
        navigationBar.setItems([UINavigationItem(title: "")], animated: false)
        navigationBar.topItem?.titleView = searchBar
        navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilterOptions))
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(hideSearchBar))
        
        searchBar.delegate = self
        
        parentViewController.view.addSubview(navigationBar)
    }
    
    @objc private func showFilterOptions() {
        if let filterVC = parentViewController.currentSearchableViewController?.getFilterViewControllerToPresent() {
            parentViewController.present(filterVC, animated: true, completion: nil)
        }
    }
    
    func sendSearchEvent() {
        parentViewController.currentSearchableViewController?.updateSearch(forText: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        parentViewController.currentSearchableViewController?.updateSearch(forText: searchText)
    }
    
    func presentSearchBar() {
        UIView.animate(withDuration: 0.2) { 
            self.navigationBar.center.x = self.parentViewController.view.bounds.width / 2
        }
        
        searchBar.becomeFirstResponder()
        isActive = true
        
        parentViewController.currentSearchableViewController?.prepareForSearch(with: self)
    }
    
    func hideSearchBar(forced: Bool = false) {
        guard isActive else { return }
        
        UIView.animate(withDuration: 0.2) { 
            self.navigationBar.center.x = self.parentViewController.view.bounds.width * 1.5
        } 
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        isActive = false
        
        parentViewController.currentSearchableViewController?.endSearch(forced: forced)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 28)!,
                     NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: "No search results...", attributes: attrs)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.lightGray
    }
}
