//
//  ManageClassesViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/28/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import CoreData

class ManageClassesViewController: UIViewController
{
    @IBOutlet weak var classesListTableView: UITableView!
    
    fileprivate var listOfClasses: [Class]!
    fileprivate var contentCounts: [Int] = []
    fileprivate var sizeCounts: [Int] = []
    fileprivate var classesToDelete: [Class] = []
    weak var delegate: ClassViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest: NSFetchRequest<Class> = Class.fetchRequest()
        listOfClasses = (try? CoreDataManager.shared.managedContext.fetch(fetchRequest)) ?? [] as [Class]
        
        for classObject in listOfClasses {
            let count = classObject.lectures.reduce(0, { (res: Int, lec: Any) -> Int in
                return res + (lec as! Lecture).contents.count
            })
            contentCounts.append(count)
            
            let size = classObject.lectures.reduce(0, { (res: Int, lec: Any) -> Int in
                var sum: Int64 = 0
                for content in (lec as! Lecture).contents {
                    sum += (content as! Content).fileSize
                }
                return res + Int(sum)
            })
            sizeCounts.append(size)
        }
        
        classesListTableView.layer.cornerRadius = 12
        classesListTableView.tableFooterView = UIView()
        classesListTableView.setEditing(true, animated: false)
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.classViewController(self, didCommitChanges: false)
    }
    
    @IBAction func applyChanges() {
        if !classesToDelete.isEmpty {
            
            let popUp = PopUp()
            
            popUp.addButton("Confirm", backgroundColor: UIColor.red, textColor: UIColor.white, showDurationStatus: false, action: { action in 
                CoreDataManager.shared.deleteClasses(self.classesToDelete)
                self.delegate?.classViewController(self, didCommitChanges: true)
            })
            
            popUp.displayWarning(message: "Classes and all of its content will be deleted and cannot be restored.")
            
        } else {
            delegate?.classViewController(self, didCommitChanges: false)
        }
    }
    
    @IBAction func removeAllClasses(_ sender: Any) {
        classesToDelete = listOfClasses
        applyChanges()
    }
}

extension ManageClassesViewController:  UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfClasses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = listOfClasses[indexPath.row].name
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 14)
        
        let size = sizeCounts[indexPath.row]
        var sizeString = ""
        if size > 1024 * 1024 {
            sizeString = "\(size / (1024 * 1024)) MB"
        } else if size > 1024 {
            sizeString = "\(size / 1024) kB"
        } else {
            sizeString = "\(size) bytes"
        }
        
        cell.detailTextLabel?.text = "\(contentCounts[indexPath.row]) content \(contentCounts[indexPath.row] == 1 ? "file" : "files") of total size \(sizeString)"
        cell.detailTextLabel?.font = UIFont(name: "Avenir Next", size: 11)
        cell.detailTextLabel?.textColor = .gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            classesToDelete.append(listOfClasses.remove(at: indexPath.row))
            classesListTableView.deleteRows(at: [indexPath], with: .left)
        }
    }

}
