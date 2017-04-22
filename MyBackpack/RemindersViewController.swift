//
//  RemindersViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/14/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class RemindersViewController: UIViewController, Updatable 
{
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    var calendarViewController: CalendarViewController!
    var remindersTableViewController: RemindersTableViewController!
    var filterViewController: RemindersFilterViewController!
    var calendarHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if childViewControllers[0] is CalendarViewController {
            calendarViewController = childViewControllers[0] as! CalendarViewController
            remindersTableViewController = childViewControllers[1] as! RemindersTableViewController
        } else {
            calendarViewController = childViewControllers[1] as! CalendarViewController
            remindersTableViewController = childViewControllers[0] as! RemindersTableViewController 
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ContentDataSource.shared.refreshRemindersOnly()
    }
    
    func update() {
        calendarViewController.calendar.reloadData() 
        remindersTableViewController.showReminders(forDate: nil)
        if let date = calendarViewController.calendar.selectedDates.first {
            calendarViewController.calendar.deselect(date)
            calendarViewController.previouslySelectedDate = nil
        }
    }
}

extension RemindersViewController: Searchable
{
    func prepareForSearch(with controller: SearchController) {
        filterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "remindersFilterOptionsVC") as! RemindersFilterViewController
        filterViewController.view.tag = 0
        filterViewController.searchController = controller
       
        remindersTableViewController.tableView.emptyDataSetSource = controller
        calendarHeight = calendarHeightConstraint.constant
        remindersTableViewController.showReminders(forDate: nil)
        
        UIView.animate(withDuration: 0.25) { 
            self.calendarHeightConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    func getFilterViewControllerToPresent() -> UIViewController {
        return self.filterViewController
    }
    
    func updateSearch(forText text: String) {
        remindersTableViewController.searchRemindersFor(text, withFilterOptions: filterViewController.filterOptions.options)
        remindersTableViewController.tableView.reloadData()
    }
    
    func endSearch() {
        UIView.animate(withDuration: 0.25) { 
            self.calendarHeightConstraint.constant = self.calendarHeight
            self.view.layoutIfNeeded()
        }
        
        filterViewController = nil
        remindersTableViewController.tableView.emptyDataSetSource = remindersTableViewController
        remindersTableViewController.showReminders(forDate: calendarViewController.calendar.selectedDates.first)
        remindersTableViewController.tableView.reloadData()
    }
}
