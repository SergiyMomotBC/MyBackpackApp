//
//  SideMenuViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/16/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import CoreData
import SideMenu

class SideMenuViewController: UIViewController, ClassViewControllerDelegate
{
    static let savedClassIndex = "savedClassIndex"
    
    @IBOutlet weak var classesTableView: UITableView!
    @IBOutlet weak var manageClassesButton: UIButton!
    @IBOutlet weak var nextClassInfoLabel: UILabel!
    
    fileprivate var selectedClassIndex: Int = -1
    fileprivate let selectedCellColor = UIColor(red: 1.0, green: 0, blue: 0.5, alpha: 0.25) 
    fileprivate let unselectedCellColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 0.25)
    fileprivate var classesList: [Class]!
    fileprivate var nextClassTimer: NextClassTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classesList = (try? CoreDataManager.shared.managedContext.fetch(Class.fetchRequest())) ?? []
        
        self.classesTableView.delegate = self
        self.classesTableView.alwaysBounceVertical = false
        
        self.nextClassTimer = NextClassTimer(forLabel: nextClassInfoLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manageClassesButton.isHidden = classesList.isEmpty
        
        if selectedClassIndex == -1 && ContentDataSource.shared.currentClass != nil {
            selectedClassIndex = classesList.index(of: ContentDataSource.shared.currentClass!) ?? -1
        }
        
        classesTableView.reloadData()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addNewClass" && classesList.count >= 8 {
            let alert = UIAlertController(title: "Action not allowed", message: "Maximum of 8 classes can be managed simultaneously.", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewClass" {
            let vc = segue.destination as! NewClassViewController
            vc.delegate = self
        } else if segue.identifier == "manageClasses" {
            let vc = segue.destination as! ManageClassesViewController
            vc.delegate = self
        }
    }
    
    func classViewController(_ classVC: UIViewController, didCommitChanges success: Bool) {
        if success {
            self.classesList = (try? CoreDataManager.shared.managedContext.fetch(Class.fetchRequest())) ?? []
            
            if classesList.isEmpty {
                selectClass(atIndex: -1)
            } else if ContentDataSource.shared.currentClass == nil || !classesList.contains(ContentDataSource.shared.currentClass!) {
                selectClass(atIndex: 0)
            }
            
            self.classesTableView.reloadData()
        }
        
        classVC.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func selectClass(atIndex index: Int) {
        selectedClassIndex = index
        UserDefaults.standard.set(index, forKey: SideMenuViewController.savedClassIndex)
        ContentDataSource.shared.loadData(forClass: index != -1 ? classesList[index] : nil)
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.classesTableView.dequeueReusableCell(withIdentifier: "classButtonCell")

        let className = cell?.contentView.subviews[0].subviews[0] as! UILabel
        className.text = self.classesList[indexPath.row].name
        cell?.contentView.subviews.first!.backgroundColor = selectedClassIndex == indexPath.row ? selectedCellColor : unselectedCellColor
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.classesTableView.dequeueReusableCell(withIdentifier: "header")?.contentView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { self.classesTableView.deselectRow(at: indexPath, animated: false) }
        
        guard indexPath.row != selectedClassIndex else { return }
        
        SideMenuManager.menuLeftNavigationController?.dismiss(animated: true, completion: nil)
        
        selectClass(atIndex: indexPath.row)
    }        
}
