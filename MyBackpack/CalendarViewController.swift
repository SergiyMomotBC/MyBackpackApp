//
//  CalendarViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/13/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController 
{
    @IBOutlet weak var calendar: FSCalendar!
    
    var previouslySelectedDate: Date?
    var controller: RemindersViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.dataSource = self
        calendar.delegate = self
        calendar.select(nil)
        calendar.today = nil
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource 
{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if let lastDate = previouslySelectedDate, lastDate == date {
            calendar.deselect(date)

            previouslySelectedDate = nil
            controller.remindersTableViewController.showReminders(forDate: nil)
        } else { 
            previouslySelectedDate = date
            controller.remindersTableViewController.showReminders(forDate: date)
        }
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return controller.remindersForDate(date).count 
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return controller.remindersForDate(date).count > 0
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return controller.remindersForDate(date).count > 0
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return SideMenuViewController.currentClass?.firstLectureDate as Date? ?? Date()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: SideMenuViewController.currentClass?.lastLectureDate as Date? ?? Date())!
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {}
}
