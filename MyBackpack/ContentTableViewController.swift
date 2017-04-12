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

class ContentTableViewController: UITableViewController, ClassObserver
{
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    lazy var blurView: UIView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        blurView.addSubview(self.indicator)
        self.indicator.center = blurView.center
        return blurView
    }()
    
    fileprivate lazy var contentPresenter = ContentPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.tableView.contentInset = UIEdgeInsetsMake(CGFloat(NavigationTabBar.height), 0, 0, 0)
        ContentDataSource.shared.addObserver(self)
        tableView.emptyDataSetSource = self
        
        self.navigationController?.navigationBar.topItem?.title = ContentDataSource.shared.classTitle
        
        if ContentDataSource.shared.currentClass == nil {
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ContentDataSource.shared.refresh()
        self.tableView.reloadData()
    }

    func classWillChange() {
        view.addSubview(blurView)
        indicator.startAnimating()
    }
    
    func classDidChange() {
        self.tableView.reloadData()
        self.navigationController?.navigationBar.topItem?.title = ContentDataSource.shared.classTitle
        
        if ContentDataSource.shared.currentClass == nil {
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
        }
        
        indicator.stopAnimating()
        blurView.removeFromSuperview()
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
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: CGFloat(self.view.bounds.size.width - 40),
                kWindowHeight: self.view.frame.height / 2.0,
                kTextHeight: 50,
                kButtonHeight: 50.0,
                kTitleFont: UIFont(name: "Avenir Next", size: 18)!,
                kTextFont: UIFont(name: "Avenir Next", size: 14)!,
                kButtonFont: UIFont(name: "Avenir Next", size: 15)!
            )
            
            let editPopUp = SCLAlertView(appearance: appearance)
            let newTitle = editPopUp.addTextField("Enter new title")
            
            editPopUp.addButton("Save", backgroundColor: .green, textColor: .white, showDurationStatus: false) {
                if let text = newTitle.text, text != ContentDataSource.shared.content(forIndexPath: indexPath)!.title! {
                    ContentDataSource.shared.updateContent(forIndexPath: indexPath, newTitle: text)
                    self.tableView.reloadData()
                }
            }
            
            editPopUp.showEdit("Edit content", subTitle: "", closeButtonTitle: "Cancel", duration: 0.0, colorStyle: 0x800040, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: .topToBottom)
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
