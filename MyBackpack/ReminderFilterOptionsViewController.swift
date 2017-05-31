//
//  ReminderFilterOptionsViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/21/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

struct RemindersFilterOptions {
    var types: [Int]
    var fromDate: Date
    var toDate: Date
}

class ReminderFilterOptionsViewController: UITableViewController, IQDropDownTextFieldDelegate
{
    fileprivate var selectedTypes: [Int]!
    fileprivate var datesInterval: (from: Date, to: Date)!
    
    @IBOutlet weak var fromDate: IQDropDownTextField!
    @IBOutlet weak var toDate: IQDropDownTextField!

    var options: RemindersFilterOptions {
        return RemindersFilterOptions(types: selectedTypes, fromDate: datesInterval.from, toDate: datesInterval.to)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        
        fromDate.isOptionalDropDown = false
        fromDate.inputAccessoryView = PickerToolbar(for: fromDate)
        fromDate.dropDownMode = .datePicker
        fromDate.delegate = self
        fromDate.tag = 0
        
        toDate.isOptionalDropDown = false
        toDate.inputAccessoryView = PickerToolbar(for: toDate)
        toDate.dropDownMode = .datePicker
        toDate.delegate = self
        toDate.tag = 1
        
        reset()
    }
    
    func textField(_ textField: IQDropDownTextField, didSelect date: Date?) {
        if let date = date {
            if textField.tag == 0 {
                if date > datesInterval.to {
                    datesInterval.to = date
                    toDate.date = date
                }
                
                datesInterval.from = date
            } else {
                if date < datesInterval.from {
                    datesInterval.from = date
                    fromDate.date = date
                }
                
                datesInterval.to = date
            }
        }
    }
    
    func reset() {
        let maxDate = Calendar.current.date(byAdding: .month, value: 1, to: (ContentDataSource.shared.currentClass!.lastLectureDate! as Date))!
        
        selectedTypes = [0, 1, 2, 3]
        datesInterval = (ContentDataSource.shared.currentClass!.firstLectureDate! as Date, maxDate)
        
        fromDate.date = datesInterval.from
        toDate.date = datesInterval.to
        
        fromDate.minimumDate = ContentDataSource.shared.currentClass?.firstLectureDate as Date?
        fromDate.maximumDate = maxDate
        
        toDate.minimumDate = ContentDataSource.shared.currentClass?.firstLectureDate as Date?
        toDate.maximumDate = maxDate
        
        if self.tableView.numberOfRows(inSection: 0) > 0 {
            for row in 0...3 {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))!
                cell.accessoryType = .checkmark
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
            if selectedTypes.count > 1 {
                cell.accessoryType = UITableViewCellAccessoryType.none
                selectedTypes.remove(at: selectedTypes.index(of: indexPath.row)!)
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            selectedTypes.append(indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 0 ? indexPath : nil
    }
}
