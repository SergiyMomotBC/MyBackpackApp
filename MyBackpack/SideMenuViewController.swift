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

protocol ClassViewControllerDelegate: class {
    func classViewController(_ classVC: UIViewController, didCommitChanges success: Bool)
}

protocol ClassObserver: class {
    func classDidChange()
}

class SideMenuViewController: UIViewController, ClassViewControllerDelegate
{
    static let savedClassIndex = "savedClassIndex"
    
    fileprivate(set) static var currentClass: Class? {
        didSet {
            self.subscriber?.classDidChange()
        }
    }
    
    static weak var subscriber: ClassObserver? = nil
 
    @IBOutlet weak var classesTableView: UITableView!
    @IBOutlet weak var manageClassesButton: UIButton!
    
    fileprivate var selectedClassIndex: Int = -1
    fileprivate let selectedCellColor = UIColor(red: 1.0, green: 0, blue: 0.5, alpha: 0.25) 
    fileprivate let unselectedCellColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 0.25)
    fileprivate var classesList: [Class]!
    
    private func initializeClasses() {
        self.classesList = (try? CoreDataManager.shared.managedContext.fetch(Class.fetchRequest())) ?? []
        
        let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: Date())
        let timeStamp = Int16(components.hour! * 60 + components.minute!)
        let weekday = Int16(components.weekday!)
            
        for (index, object) in self.classesList.enumerated() {
            for day in object.days.allObjects as! [ClassDay] {
                if timeStamp >= day.startTime && timeStamp <= day.endTime && day.day == weekday {
                    SideMenuViewController.currentClass = object
                    selectedClassIndex = index
                    return
                }
            }
        }
        
        if let index = UserDefaults.standard.object(forKey: SideMenuViewController.savedClassIndex) as? Int {
            SideMenuViewController.currentClass = index != -1 ? self.classesList[index] : nil
            selectedClassIndex = index
        } else if self.classesList.count > 0 {
            SideMenuViewController.currentClass = self.classesList.first
            selectedClassIndex = 0
        } else {
            SideMenuViewController.currentClass = nil
            selectedClassIndex = -1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeClasses()
    
        self.classesTableView.delegate = self
        self.classesTableView.alwaysBounceVertical = false
        self.classesTableView.emptyDataSetSource = self
        self.classesTableView.emptyDataSetDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manageClassesButton.isHidden = classesList.isEmpty
        classesTableView.reloadData()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addNewClass" && classesList.count >= 8 {
            let popUp = PopUp()
            popUp.displayError(message: "Maximum of 8 classes can be managed by My Backpack application at the same time.")
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
            let previousCount = self.classesList.count
            self.classesList = (try? CoreDataManager.shared.managedContext.fetch(Class.fetchRequest())) ?? []
            
            if previousCount < self.classesList.count {
                selectClass(atIndex: previousCount)
            } else if self.classesList.isEmpty {
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
        let cell = self.classesTableView.dequeueReusableCell(withIdentifier: "classButtonCell", for: indexPath)

        if let className = cell.contentView.subviews[0].subviews[0] as? UILabel {
            className.text = self.classesList[indexPath.row].name
            cell.contentView.subviews.first!.backgroundColor = selectedClassIndex == indexPath.row ? selectedCellColor : unselectedCellColor
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return !self.classesList.isEmpty ? self.classesTableView.dequeueReusableCell(withIdentifier: "header")?.contentView : UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.classesTableView.deselectRow(at: indexPath, animated: false) 
        SideMenuManager.menuLeftNavigationController?.dismiss(animated: true, completion: nil)
        
        if indexPath.row != selectedClassIndex { 
            selectClass(atIndex: indexPath.row)
        }
    }        
}

extension SideMenuViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 20)!,
                     NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: "Empty :(", attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 16)!,
                     NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: "This application will become useful as soon as you add your first class.", attributes: attrs)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 16)!,
                     NSForegroundColorAttributeName: state == .normal ? UIColor(red: 1.0, green: 1.0, blue: 102/255.0, alpha: 1.0) : UIColor.lightGray]
        return NSAttributedString(string: "Add your first class", attributes: attrs)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        performSegue(withIdentifier: "addNewClass", sender: nil)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return self.classesTableView.frame.height / -8.0
    }
}
