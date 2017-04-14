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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(forReminder reminder: Reminder) {
        titleLabel.text = reminder.title
        let typeName = ReminderType.typeNames[Int(reminder.typeID)] //• \()"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        detailsLabel.text = "\(typeName) • \(dateFormatter.string(from: reminder.date! as Date))"
    }
}
