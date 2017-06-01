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
import DZNEmptyDataSet

class SideMenuViewController: UIViewController, ClassViewControllerDelegate, DZNEmptyDataSetSource
{
    static let savedClassIndex = "savedClassIndex"
    
    fileprivate(set) static var currentClass: Class? {
        didSet {
            self.subscribers.forEach { $0.classDidChange() }
        }
    }
    
    private static var subscribers: [ClassObserver] = []
    
    static func addObserver(_ observer: ClassObserver) {
        self.subscribers.append(observer)
    }
    
    @IBOutlet weak var classesTableView: UITableView!
    @IBOutlet weak var manageClassesButton: UIButton!
    @IBOutlet weak var nextClassInfoLabel: UILabel!
    
    fileprivate var selectedClassIndex: Int = -1
    fileprivate let selectedCellColor = UIColor(red: 1.0, green: 0, blue: 0.5, alpha: 0.25) 
    fileprivate let unselectedCellColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 0.25)
    fileprivate var classesList: [Class]!
    
    func initClass() {
        let remindersRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        let reminders = (try? CoreDataManager.shared.managedContext.fetch(remindersRequest)) ?? []
        
        let now = Date()
        reminders.forEach{ reminder in
            if (reminder.date! as Date) < now {
                CoreDataManager.shared.managedContext.delete(reminder)
            }
        }
        
        CoreDataManager.shared.saveContext()
        
        let fetchRequest: NSFetchRequest<Class> = Class.fetchRequest()
        
        let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: Date())
        let timeStamp = Int16(components.hour! * 60 + components.minute!)
        let weekday = Int16(components.weekday!)
        
        if let classes = try? CoreDataManager.shared.managedContext.fetch(fetchRequest) {
            
            for object in classes {
                for day in object.days?.allObjects as! [ClassDay] {
                    if timeStamp >= day.startTime && timeStamp <= day.endTime && day.day == weekday {
                        SideMenuViewController.currentClass = object
                        return
                    }
                }
            }
            
            if UserDefaults.standard.object(forKey: SideMenuViewController.savedClassIndex) != nil {
                let index = UserDefaults.standard.integer(forKey: SideMenuViewController.savedClassIndex)
                if index != -1 {
                    SideMenuViewController.currentClass = classes[index]
                } else {
                    SideMenuViewController.currentClass = nil
                }
            } else if classes.count > 0 {
                SideMenuViewController.currentClass = classes.first
            } else {
                SideMenuViewController.currentClass = nil
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initClass()
        
        classesList = (try? CoreDataManager.shared.managedContext.fetch(Class.fetchRequest())) ?? []
        
        self.classesTableView.delegate = self
        self.classesTableView.alwaysBounceVertical = false
        self.classesTableView.emptyDataSetSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manageClassesButton.isHidden = classesList.isEmpty
        
        if SideMenuViewController.currentClass != nil {
            selectedClassIndex = classesList.index(of: SideMenuViewController.currentClass!) ?? -1
        }
        
        classesTableView.reloadData()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addNewClass" && classesList.count >= 8 {
            let popUp = PopUp()
            popUp.displayError(message: "Maximum of 8 classes can be managed simultaneously.")
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
        classVC.dismiss(animated: true, completion: nil)
        
        if success {
            self.classesList = (try? CoreDataManager.shared.managedContext.fetch(Class.fetchRequest())) ?? []
            
            if self.classesList.isEmpty {
                selectClass(atIndex: -1)
            } else if SideMenuViewController.currentClass == nil || !self.classesList.contains(SideMenuViewController.currentClass!) {
                self.selectClass(atIndex: 0)
            }
            
            self.classesTableView.reloadData()
        }
    }
    
    fileprivate func selectClass(atIndex index: Int) {
        selectedClassIndex = index
        UserDefaults.standard.set(index, forKey: SideMenuViewController.savedClassIndex)
        SideMenuViewController.currentClass = index != -1 ? classesList[index] : nil
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 20)!,
                     NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: "Your backpack is empty.", attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 16)!,
                     NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: "You can add your first class by tapping on the 'Add...' button above.", attributes: attrs)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return self.classesTableView.frame.height / -8
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
        self.classesTableView.deselectRow(at: indexPath, animated: false) 
        SideMenuManager.menuLeftNavigationController?.dismiss(animated: true, completion: nil)
        
        if indexPath.row != selectedClassIndex { 
            selectClass(atIndex: indexPath.row)
        }
    }        
}
