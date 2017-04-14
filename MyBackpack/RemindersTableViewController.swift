//
//  RemindersTableViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/13/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import SCLAlertView

class RemindersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContentDataSource.shared.remindersCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell") as! ReminderTableViewCell
        cell.setup(forReminder: ContentDataSource.shared.reminder(forRow: indexPath.row)!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "header")!.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: CGFloat(self.view.bounds.size.width - 40),
            kButtonHeight: 50.0,
            kTitleFont: UIFont(name: "Avenir Next", size: 18)!,
            kTextFont: UIFont(name: "Avenir Next", size: 14)!,
            kButtonFont: UIFont(name: "Avenir Next", size: 15)!
        )
        
        let reminder = ContentDataSource.shared.reminder(forRow: indexPath.row)!
        
        let editPopUp = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width - 66, height: self.view.bounds.size.height))
        textView.isEditable = false
        textView.layer.cornerRadius = 8.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.text = reminder.remark!.isEmpty ? "No description" : reminder.remark
        
        editPopUp.customSubview = textView
        
        editPopUp.showInfo(reminder.title!, subTitle: "", closeButtonTitle: "Close", duration: 0.0, colorStyle: 0x800040, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: .topToBottom)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
