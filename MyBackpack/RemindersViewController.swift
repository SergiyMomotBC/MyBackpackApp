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
    var calendarViewController: CalendarViewController!
    var remindersTableViewController: RemindersTableViewController!
    
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
    
    func update() {
        calendarViewController.calendar.reloadData()
        remindersTableViewController.tableView.reloadData()
    }
}
