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

class SideMenuViewController: UIViewController 
{
    @IBOutlet weak var classesTableView: UITableView!
    
    lazy var classList: [Class] = {
        let request: NSFetchRequest<Class> = Class.fetchRequest()
        return (try? CoreDataManager.shared.managedContext.fetch(request)) ?? [Class]()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classesTableView.delegate = self
        
        /*
        let newClass1 = NSEntityDescription.insertNewObject(forEntityName: "Class", into: CoreDataManager.shared.managedContext) as! Class
        newClass1.name = "CISC 3325"
        
        let newClass2 = NSEntityDescription.insertNewObject(forEntityName: "Class", into: CoreDataManager.shared.managedContext) as! Class
        newClass2.name = "CISC 3220"
        
        let newClass3 = NSEntityDescription.insertNewObject(forEntityName: "Class", into: CoreDataManager.shared.managedContext) as! Class
        newClass3.name = "CHEM 1050"
        
        let newClass4 = NSEntityDescription.insertNewObject(forEntityName: "Class", into: CoreDataManager.shared.managedContext) as! Class
        newClass4.name = "CISC 3350"
        
        let newClass5 = NSEntityDescription.insertNewObject(forEntityName: "Class", into: CoreDataManager.shared.managedContext) as! Class
        newClass5.name = "CISC 3150"
        
        let newClass6 = NSEntityDescription.insertNewObject(forEntityName: "Class", into: CoreDataManager.shared.managedContext) as! Class
        newClass6.name = "CISC 4900"
        
        CoreDataManager.shared.saveContext()
         */
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.classesTableView.dequeueReusableCell(withIdentifier: "classButtonCell")
        
        let className = cell?.contentView.subviews[1] as! UILabel
        className.text = self.classList[indexPath.row].name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.classesTableView.dequeueReusableCell(withIdentifier: "header")?.contentView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.classesTableView.deselectRow(at: indexPath, animated: false)
        SideMenuManager.menuLeftNavigationController?.dismiss(animated: true, completion: nil)
    }
}
