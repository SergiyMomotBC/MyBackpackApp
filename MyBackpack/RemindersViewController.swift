//
//  RemindersViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/14/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import CoreData

class RemindersViewController: UIViewController
{
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    var reminders: [Reminder] = []
    fileprivate var isSearching = false
    
    var calendarViewController: CalendarViewController!
    var remindersTableViewController: RemindersTableViewController!
    var filterViewController: RemindersFilterViewController!
    var calendarHeight: CGFloat!
    
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
        if childViewControllers[0] is CalendarViewController {
            calendarViewController = childViewControllers[0] as! CalendarViewController
            remindersTableViewController = childViewControllers[1] as! RemindersTableViewController
        } else {
            calendarViewController = childViewControllers[1] as! CalendarViewController
            remindersTableViewController = childViewControllers[0] as! RemindersTableViewController 
        }
        
        calendarViewController.controller = self
        remindersTableViewController.controller = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isSearching {
            loadData()
        }
    }
    
    func loadData(animated: Bool = false) {
        self.reminders.removeAll()
        
        guard let currentClass = SideMenuViewController.currentClass else {
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
            
            let fetchReminders: NSFetchRequest<Reminder> = Reminder.fetchRequest()
            fetchReminders.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            fetchReminders.predicate = NSPredicate(format: "inClass.name == %@", currentClass.name)
            fetchReminders.fetchBatchSize = 10
                
            self.reminders = (try? CoreDataManager.shared.managedContext.fetch(fetchReminders)) ?? []
            
            DispatchQueue.main.async {
                self.calendarViewController.calendar.reloadData() 
                self.remindersTableViewController.reminders = self.reminders
                self.remindersTableViewController.tableView.reloadData()
                
                if let date = self.calendarViewController.calendar.selectedDates.first {
                    self.calendarViewController.calendar.deselect(date)
                    self.calendarViewController.previouslySelectedDate = nil
                }
                
                if animated {
                    self.indicator.stopAnimating()
                    self.blurView.removeFromSuperview()
                }
            }
        }
    }
    
    func remindersForDate(_ date: Date) -> [Reminder] {
        var results: [Reminder] = []
        
        for reminder in reminders {
            if Calendar.current.compare(date, to: reminder.date as Date, toGranularity: .day) == .orderedSame {
                results.append(reminder)
            }
        }
        
        return results
    }
}

extension RemindersViewController: Searchable
{
    func prepareForSearch(with controller: SearchController) {
        isSearching = true
        
        filterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "remindersFilterOptionsVC") as! RemindersFilterViewController
        filterViewController.view.tag = 0
        filterViewController.searchController = controller
       
        remindersTableViewController.tableView.emptyDataSetSource = controller
        
        calendarHeight = calendarHeightConstraint.constant
        remindersTableViewController.showReminders(forDate: nil, isSearching: true)
        
        UIView.animate(withDuration: 0.25) { 
            self.calendarHeightConstraint.constant = self.containerView.frame.height * 2
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
        isSearching = false
        
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
