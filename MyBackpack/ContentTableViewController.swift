//
//  ContentTableViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/20/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SCLAlertView

class ContentTableViewController: UITableViewController, Updatable
{
    fileprivate lazy var contentPresenter = ContentPresenter()
    fileprivate var filterViewController: FilterViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.tableView.contentInset = UIEdgeInsetsMake(CGFloat(NavigationTabBar.height), 0, 0, 0)
        tableView.emptyDataSetSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ContentDataSource.shared.refresh()
    }
    
    func update() {
        self.tableView.reloadData()
    }
}    

extension ContentTableViewController: Searchable
{
    func prepareForSearch(with controller: SearchController) {
        filterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "filterOptionsVC") as! FilterViewController
        filterViewController.view.tag = 0
        filterViewController.searchController = controller
        
        self.tableView.emptyDataSetSource = controller
        ContentDataSource.shared.prepareForSearching()
    }
    
    func getFilterViewControllerToPresent() -> UIViewController {
        return self.filterViewController
    }

    
    func updateSearch(forText text: String) {
        ContentDataSource.shared.updateDataForSearchString(text, withFilterOptions: filterViewController.filterOptions.options)
        self.tableView.reloadData()
    }
    
    func endSearch() {
        ContentDataSource.shared.endSearching()
        self.tableView.emptyDataSetSource = self
        self.filterViewController = nil
        self.tableView.reloadData()
    }
}

extension ContentTableViewController 
{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ContentDataSource.shared.lecturesCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContentDataSource.shared.contentsCount(forLecture: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContentTableViewCell
        
        cell.prepareCell(forContent: ContentDataSource.shared.content(forIndexPath: indexPath)!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        self.contentPresenter.presentContent(ContentDataSource.shared.content(forIndexPath: indexPath)!, inViewController: self)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: " Delete") { (action, indexPath) in
            
            self.tableView.beginUpdates()
            
            let count = ContentDataSource.shared.contentsCount(forLecture: indexPath.section)
            ContentDataSource.shared.removeContent(atIndexPath: indexPath)
            
            if count == 1 {
                self.tableView.deleteSections([indexPath.section], with: .top)
            } else {
                self.tableView.deleteRows(at: [indexPath], with: .left)
            }
            
            self.tableView.endUpdates()
        }
        
        let edit = UITableViewRowAction(style: .normal, title: " Edit     ") { (action, indexPath) in
            let editPopUp = PopUp()
            editPopUp.appearance.setkWindowHeight(self.view.bounds.size.height / 2.0)
            
            let newTitle = editPopUp.addTextField("Enter new title")
            
            editPopUp.addButton("Save", backgroundColor: nil, textColor: .white, showDurationStatus: false) {
                if let text = newTitle.text, text != ContentDataSource.shared.content(forIndexPath: indexPath)!.title! {
                    ContentDataSource.shared.updateContent(forIndexPath: indexPath, newTitle: text)
                    self.tableView.reloadData()
                }
            }
            
            editPopUp.displayEdit(title: "Edit content")
            
            self.tableView.setEditing(false, animated: true)
        }
        
        edit.backgroundColor = UIColor(red: 0.0, green: 191/255.0, blue: 1.0, alpha: 1.0)
        
        return [delete, edit]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "header")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        let headerLabel = cell?.contentView.subviews.first as! UILabel
        let lecture = ContentDataSource.shared.lecture(forSection: section)!
        
        headerLabel.text = "Lecture \(lecture.countID + 1) • \(dateFormatter.string(from: lecture.date! as Date))"
        
        return cell?.contentView
    }
}

extension ContentTableViewController: DZNEmptyDataSetSource
{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 24)!,
                     NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: "No content so far.", attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 16)!,
                     NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: "You can add new content by pressing a '+' button in the upper right corner.", attributes: attrs)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.lightGray
    }
}
