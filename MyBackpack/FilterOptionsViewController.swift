//
//  FilterOptionsViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/1/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

struct FilterOptions {
    var types: [Int]
    var fromLecture: Int
    var toLecture: Int
}

class FilterOptionsViewController: UITableViewController, IQDropDownTextFieldDelegate
{
    fileprivate var selectedTypes: [Int]!
    fileprivate var lecturesInterval: (from: Int, to: Int)!
    
    @IBOutlet weak var toLecture: IQDropDownTextField!
    @IBOutlet weak var fromLecture: IQDropDownTextField!
    
    @objc private func donePicker() {
        if fromLecture.isEditing {
            fromLecture.endEditing(true)
        } else {
            toLecture.endEditing(true)
        }
    }
    
    var options: FilterOptions {
        return FilterOptions(types: selectedTypes, fromLecture: lecturesInterval.from, toLecture: lecturesInterval.to)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        
        fromLecture.isOptionalDropDown = false
        fromLecture.inputAccessoryView = PickerToolbar(for: fromLecture)
        fromLecture.delegate = self
        fromLecture.tag = 0
        
        toLecture.isOptionalDropDown = false
        toLecture.inputAccessoryView = PickerToolbar(for: toLecture)
        toLecture.delegate = self
        toLecture.tag = 1
        
        let lecturesList = Class.retrieveLecturesList(forClass: ContentDataSource.shared.currentClass).reversed() as [String]
        fromLecture.itemList = lecturesList
        toLecture.itemList = lecturesList
        
        reset()
    }

    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?) {
        let index = textField.selectedRow
        
        if textField.tag == 0 {
            if index > lecturesInterval.to {
                lecturesInterval.to = index
                toLecture.selectedRow = index
            } 
            
            lecturesInterval.from = index
        } else {
            if index < lecturesInterval.from {
                lecturesInterval.from = index
                fromLecture.selectedRow = index
            }
            
            lecturesInterval.to = index
        }
    }
    
    func reset() {
        selectedTypes = [0, 1, 2, 3]
        lecturesInterval = (0, toLecture.itemList.count - 1)
        
        fromLecture.selectedRow = lecturesInterval.from
        toLecture.selectedRow = lecturesInterval.to
        
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
