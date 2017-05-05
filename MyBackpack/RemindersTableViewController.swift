//
//  RemindersTableViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/13/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import SCLAlertView
import DZNEmptyDataSet

class RemindersTableViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var reminders: [Reminder] = []
    fileprivate var headerText = "All reminders:"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.alwaysBounceVertical = false
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reminders = ContentDataSource.shared.reminders(forDate: nil)
        tableView.reloadData()
    }
    
    func showReminders(forDate date: Date?) {
        reminders = ContentDataSource.shared.reminders(forDate: date)
        
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            headerText = "Reminders at \(dateFormatter.string(from: date)):"
        } else {
            headerText = "All reminders:"
        }
        
        tableView.reloadData()
    }
    
    func searchRemindersFor(_ text: String, withFilterOptions options: RemindersFilterOptions) {
        self.reminders = ContentDataSource.shared.reminders(forDate: nil).filter({
            $0.title!.lowercased().contains(text.isEmpty ? $0.title!.lowercased() : text.lowercased()) 
                && options.types.contains(Int($0.typeID)) 
                && (options.fromDate...options.toDate).contains($0.date! as Date)
        })
    }
}

extension RemindersTableViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell") as! ReminderTableViewCell
        cell.setup(forReminder: reminders[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "header")!.contentView
        
        if let headerLabel = headerView.subviews.first as? UILabel {
            headerLabel.text = headerText
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let reminder = reminders[indexPath.row]
        
        let editPopUp = PopUp()
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width - 66, height: self.view.bounds.size.height))
        textView.isEditable = false
        textView.layer.cornerRadius = 8.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.text = reminder.remark!.isEmpty ? "No description" : reminder.remark
        
        editPopUp.customSubview = textView
        editPopUp.displayInfo(title: reminder.title!)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ContentDataSource.shared.removeReminder(atRow: indexPath.row)
            reminders.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.endUpdates()
        }
    }
}

extension RemindersTableViewController: DZNEmptyDataSetSource
{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 24)!,
                     NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: "No reminders so far.", attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 16)!,
                     NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: "You can add new reminders by pressing a '+' button in the upper right corner.", attributes: attrs)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.lightGray
    }
}
