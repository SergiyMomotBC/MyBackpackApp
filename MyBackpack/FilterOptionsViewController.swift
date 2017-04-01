//
//  FilterOptionsViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/1/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class FilterOptionsViewController: UITableViewController 
{
    var selectedTypes = [0, 1, 2, 3]
    var lecturesList: [String] = []
    var lecturesInterval: (from: Int, to: Int)!

    @IBOutlet weak var toLecture: IQDropDownTextField!
    @IBOutlet weak var fromLecture: IQDropDownTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        lecturesList = Class.retrieveLecturesList(forClass: ContentDataSource.shared.currentClass).reversed()
        lecturesInterval = (0, lecturesList.count - 1)
        
        fromLecture.isOptionalDropDown = false
        fromLecture.itemList = lecturesList
        fromLecture.selectedRow = 0
        
        toLecture.isOptionalDropDown = false
        toLecture.itemList = lecturesList
        toLecture.selectedRow = lecturesList.count - 1
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
}
