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
import CoreData

class ContentTableViewController: UITableViewController
{
    fileprivate lazy var contentPresenter = ContentPresenter()
    fileprivate var filterViewController: FilterViewController!
    
    fileprivate var contentObjects: [[Content]] = []
    fileprivate var backup: [[Content]]!
    fileprivate var isSearching = false
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    lazy var blurView: UIView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        blurView.addSubview(self.indicator)
        self.indicator.center = blurView.center
        return blurView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(CGFloat(NavigationTabBar.height), 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGFloat(NavigationTabBar.height), 0, 0, 0)
        tableView.emptyDataSetSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isSearching {
            self.loadData()
        }
    }
    
    func loadData(animated: Bool = false) {
        self.contentObjects.removeAll()
        
        guard let currentClass = SideMenuViewController.currentClass else {
            self.tableView.reloadData()
            return
        }
        
        if animated {
            self.view.addSubview(blurView)
            indicator.startAnimating()
        }
        
        DispatchQueue.global().async {
            if animated {
                usleep(250_000)
            }
            
            let lectures = (currentClass.lectures.allObjects as! [Lecture]).sorted { $0.date as Date > $1.date as Date }
            
            for lecture in lectures {
                let fetchRequest: NSFetchRequest<Content> = Content.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
                fetchRequest.predicate = NSPredicate(format: "lecture.countID == %d AND lecture.inClass.name == %@", lecture.countID, currentClass.name) 
                fetchRequest.fetchBatchSize = 10
                self.contentObjects.append((try? CoreDataManager.shared.managedContext.fetch(fetchRequest)) as [Content]? ?? [])
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if animated {
                    self.indicator.stopAnimating()
                    self.blurView.removeFromSuperview()
                }
            }
        }
    }
}    

extension ContentTableViewController: Searchable
{
    func prepareForSearch(with controller: SearchController) {
        filterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "filterOptionsVC") as! FilterViewController
        filterViewController.view.tag = 0
        filterViewController.searchController = controller
        self.tableView.emptyDataSetSource = controller
        self.backup = self.contentObjects
        isSearching = true
    }
    
    func getFilterViewControllerToPresent() -> UIViewController {
        return self.filterViewController
    }

    func updateSearch(forText text: String) {
        self.contentObjects.removeAll()
        
        let options = filterViewController.filterOptions.options
        for lecture in backup! {
            let result = lecture.filter { 
                $0.title.lowercased().contains(text.isEmpty ? $0.title.lowercased() : text.lowercased()) 
                    && options.types.contains(Int($0.typeID)) 
                    && (options.fromLecture...options.toLecture).contains(Int($0.lecture.countID))
            }
            
            if result.count > 0 {
                contentObjects.append(result)
            }
        }
        
        self.tableView.reloadData()
    }
    
    func endSearch(forced: Bool) {
        isSearching = false
        self.tableView.emptyDataSetSource = self
        self.filterViewController = nil
        self.contentObjects = backup
        if !forced {
            self.tableView.reloadData()
        }
        self.backup = nil
    }
}

extension ContentTableViewController 
{
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y < -CGFloat(NavigationTabBar.height) {
            tableView.contentOffset.y = -CGFloat(NavigationTabBar.height)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return contentObjects.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentObjects[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContentTableViewCell
        cell.prepareCell(forContent: self.contentObjects[indexPath.section][indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        self.contentPresenter.presentContent(self.contentObjects[indexPath.section][indexPath.row], inViewController: self)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: " Delete") { (action, indexPath) in
            
            self.tableView.beginUpdates()
            
            let count = self.contentObjects[indexPath.section].count
           
            if self.backup != nil {
                self.backup[indexPath.section].remove(at: indexPath.row)
            }
            
            let content = self.contentObjects[indexPath.section].remove(at: indexPath.row)
            
            let lecture = content.lecture
            
            lecture.removeFromContents(content)
            CoreDataManager.shared.managedContext.delete(content)
            
            if lecture.contents.count == 0 {
                if self.backup != nil {
                    self.backup.remove(at: indexPath.section)
                }
                
                self.contentObjects.remove(at: indexPath.section)
                SideMenuViewController.currentClass!.removeFromLectures(lecture)
                CoreDataManager.shared.managedContext.delete(lecture)
            }
            
            do {
                try FileManager.default.removeItem(at: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(content.resourceURL))
                
                let type = ContentType(rawValue: Int(content.typeID))!
                if type == .Picture || type == .Video {
                    let thumbnailPath = content.resourceURL.replacingOccurrences(of: type == .Picture ? ".jpeg" : ".mov", with: "_t.jpeg") 
                    try FileManager.default.removeItem(at: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(thumbnailPath))
                }
            } catch {
                PopUp().displayError(message: "File could not be deleted.")
            }
            
            CoreDataManager.shared.saveContext()
            
            if count == 1 {
                self.tableView.deleteSections([indexPath.section], with: .fade)
            } else {
                self.tableView.deleteRows(at: [indexPath], with: .left)
            }
            
            self.tableView.endUpdates()
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Rename   ") { (action, indexPath) in
            let editPopUp = PopUp()
            editPopUp.appearance.setkWindowHeight(self.view.bounds.size.height / 2.0)
            
            let newTitle = editPopUp.addTextField("Enter new title")
            
            editPopUp.addButton("Save", backgroundColor: nil, textColor: .white, showDurationStatus: false) {
                if let text = newTitle.text, text != self.contentObjects[indexPath.section][indexPath.row].title {
                    self.contentObjects[indexPath.section][indexPath.row].title = newTitle.text ?? ""
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
        let lecture = self.contentObjects[section][0].lecture
        
        headerLabel.text = "Lecture on \(dateFormatter.string(from: lecture.date as Date))"
        
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
        return NSAttributedString(string: "You can add new content by pressing the '+' button in the upper right corner.", attributes: attrs)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.lightGray
    }
}
