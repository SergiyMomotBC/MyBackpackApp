//
//  SearchController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/31/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

fileprivate class NoCancelButtonSearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setShowsCancelButton(false, animated: false)
    }
}

class SearchController: NSObject, UISearchBarDelegate
{
    var searchBar: UISearchBar
    var navigationBar: UINavigationBar
    var parentViewController: UIPageViewController
    var targetTableView: UITableView!
    
    var filterViewController: FilterViewController
    
    init(forViewController vc: UIPageViewController) {
        parentViewController = vc
        
        filterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "filterOptionsVC") as! FilterViewController
        filterViewController.view.tag = 0
        
        navigationBar = UINavigationBar(frame: CGRect(x: vc.view.bounds.width, y: 0.0, width: vc.view.bounds.width, height: CGFloat(NavigationTabBar.height - 0.5)))
        
        navigationBar.layer.zPosition = CGFloat.greatestFiniteMagnitude - 1.0
        navigationBar.tintColor = .white
        navigationBar.barTintColor = vc.navigationController?.navigationBar.barTintColor 
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.setItems([UINavigationItem(title: "")], animated: false)
        
        searchBar = NoCancelButtonSearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search for content..."
        (searchBar.value(forKey: "searchField") as? UITextField)?.textColor = .white
        
        super.init()
        
        navigationBar.topItem?.titleView = searchBar
        navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilterOptions))
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(hideSearchBar))
        
        searchBar.delegate = self
        
        vc.view.addSubview(navigationBar)
    }
    
    @objc private func showFilterOptions() {
        parentViewController.present(filterViewController, animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        ContentDataSource.shared.updateDataForSearchString(searchText)
        targetTableView.reloadData()
    }
    
    func presentSearchBar(withResultsShowingIn tableView: UITableView) {
        ContentDataSource.shared.prepareForSearching()
        targetTableView = tableView
        
        UIView.animate(withDuration: 0.2) { 
            self.navigationBar.center.x = self.parentViewController.view.bounds.width / 2
        }
        
        searchBar.becomeFirstResponder()
    }
    
    @objc private func hideSearchBar() {
        UIView.animate(withDuration: 0.2) { 
            self.navigationBar.center.x = self.parentViewController.view.bounds.width * 1.5
        } 
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        ContentDataSource.shared.endSearching()
        targetTableView.reloadData()
        targetTableView = nil
    }
}
