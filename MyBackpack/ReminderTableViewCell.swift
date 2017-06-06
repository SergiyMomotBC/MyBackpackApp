//
//  ReminderTableViewCell.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/14/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell 
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var container: UIView!
    
    func setup(forReminder reminder: Reminder) {
        titleLabel.text = reminder.title
        let typeName = ReminderType.typeNames[Int(reminder.typeID)]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        detailsLabel.text = "\(typeName) • \(dateFormatter.string(from: reminder.date as Date))" + (reminder.shouldNotify ? " • 🔔" : "")
        container.backgroundColor = (reminder.date as Date) < Date() ? UIColor(white: 0.9, alpha: 1.0) : UIColor.white
    }
}
