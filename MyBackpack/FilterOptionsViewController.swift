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
    fileprivate var lecturesList: [String]!
    private var shouldReset = false
    
    @IBOutlet weak var toLecture: IQDropDownTextField!
    @IBOutlet weak var fromLecture: IQDropDownTextField!
    
    fileprivate lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .blue
        toolbar.sizeToFit() 
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton, space], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
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
        fromLecture.inputAccessoryView = toolbar
        fromLecture.delegate = self
        fromLecture.tag = 0
        
        toLecture.isOptionalDropDown = false
        toLecture.inputAccessoryView = toolbar
        toLecture.delegate = self
        toLecture.tag = 1
    }

    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?) {
        if let index = lecturesList.index(of: item!) {
            if textField.tag == 0 {
                lecturesInterval.from = index
            } else {
                lecturesInterval.to = index
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldReset {
            reset()
            shouldReset = false
        }
    }
    
    func prepare() {
        lecturesList = Class.retrieveLecturesList(forClass: ContentDataSource.shared.currentClass).reversed()
        fromLecture.itemList = lecturesList
        toLecture.itemList = lecturesList
        
        selectedTypes = [0, 1, 2, 3]
        lecturesInterval = (0, lecturesList.count - 1)
        
        shouldReset = true
    }
    
    func reset() {
        fromLecture.selectedRow = lecturesInterval.from
        toLecture.selectedRow = lecturesInterval.to
        
        for row in 0...3 {
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))!
            cell.accessoryType = .checkmark
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
