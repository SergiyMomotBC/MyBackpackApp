//
//  CalendarViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/13/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    var heightConstraint: NSLayoutConstraint!
    var previouslySelectedDate: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.dataSource = self
        calendar.delegate = self
        calendar.select(nil)
        calendar.today = nil
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        for constraint in view.superview!.constraints {
            if constraint.identifier == "height" {
                heightConstraint = constraint
            }
        }
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if let lastDate = previouslySelectedDate, lastDate == date {
            calendar.deselect(date)
            previouslySelectedDate = nil
        } else {
            previouslySelectedDate = date
        }
        
        //send event to parent with selected date or nil if no selection
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return ContentDataSource.shared.reminders(forDate: date).count
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return ContentDataSource.shared.reminders(forDate: date).count > 0
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return ContentDataSource.shared.reminders(forDate: date).count > 0
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return ContentDataSource.shared.currentClass?.firstLectureDate as Date? ?? Date()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return ContentDataSource.shared.currentClass?.lastLectureDate as Date? ?? Date()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        UIView.animate(withDuration: 0.3, animations: { 
            self.heightConstraint.constant = bounds.size.height
        })
    }
}
