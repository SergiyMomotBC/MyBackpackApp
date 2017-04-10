//
//  SearchController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/31/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

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
    
    private var parentViewController: UIPageViewController
    private var savedEmptyDataSource: DZNEmptyDataSetSource!
    private var targetTableView: UITableView!
    private var filterViewController: FilterViewController
    
    init(forViewController vc: UIPageViewController) {
        parentViewController = vc
        
        filterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "filterOptionsVC") as! FilterViewController
        filterViewController.view.tag = 0
        
        super.init()
        
        navigationBar.setItems([UINavigationItem(title: "")], animated: false)
        navigationBar.topItem?.titleView = searchBar
        navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilterOptions))
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(hideSearchBar))
        
        searchBar.delegate = self
        filterViewController.searchController = self
        
        parentViewController.view.addSubview(navigationBar)
    }
    
    @objc private func showFilterOptions() {
        parentViewController.present(filterViewController, animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearch()
    }
    
    func updateSearch() {
        ContentDataSource.shared.updateDataForSearchString(searchBar.text ?? "", withFilterOptions: filterViewController.filterOptions.options)
        targetTableView.reloadData()
    }
    
    func presentSearchBar(withResultsShowingIn tableView: UITableView) {
        filterViewController.filterOptions.prepare()
        ContentDataSource.shared.prepareForSearching()
        targetTableView = tableView
        savedEmptyDataSource = tableView.emptyDataSetSource
        tableView.emptyDataSetSource = self
        
        UIView.animate(withDuration: 0.2) { 
            self.navigationBar.center.x = self.parentViewController.view.bounds.width / 2
        }
        
        searchBar.becomeFirstResponder()
        isActive = true
    }
    
    func hideSearchBar() {
        guard isActive else {
            return
        }
        
        UIView.animate(withDuration: 0.2) { 
            self.navigationBar.center.x = self.parentViewController.view.bounds.width * 1.5
        } 
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        ContentDataSource.shared.endSearching()
        
        targetTableView.emptyDataSetSource = savedEmptyDataSource
        savedEmptyDataSource = nil
        
        targetTableView.reloadData()
        targetTableView = nil
        isActive = false
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
