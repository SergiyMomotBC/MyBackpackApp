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

class SideMenuViewController: UIViewController, NewClassViewControllerDelegate
{
    fileprivate(set) static var currentClass: Class = {
       return try! CoreDataManager.shared.managedContext.fetch(Class.fetchRequest()).first!
    }()
    
    @IBOutlet weak var classesTableView: UITableView!
    
    lazy var classList: [Class] = {
        let request: NSFetchRequest<Class> = Class.fetchRequest()
        return (try? CoreDataManager.shared.managedContext.fetch(request)) ?? [Class]()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classesTableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewClass" {
            let vc = segue.destination as! NewClassViewController
            vc.delegate = self
        }
    }
    
    func newClassViewController(_ newClassVC: NewClassViewController, didFinishWithSuccess success: Bool) {
        if success {
            self.classList = try! CoreDataManager.shared.managedContext.fetch(Class.fetchRequest())
            self.classesTableView.reloadData()
        }
        
        newClassVC.dismiss(animated: true, completion: nil)
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

        let className = cell?.contentView.subviews[0].subviews[0] as! UILabel
        className.text = self.classList[indexPath.row].name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.classesTableView.dequeueReusableCell(withIdentifier: "header")?.contentView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.classesTableView.deselectRow(at: indexPath, animated: false)
        SideMenuManager.menuLeftNavigationController?.dismiss(animated: true, completion: nil)
        SideMenuViewController.currentClass = classList[indexPath.row]
    }
}
