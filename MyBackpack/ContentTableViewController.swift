//
//  ContentTableViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/20/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import AVKit
import NYTPhotoViewer

class ContentTableViewController: UITableViewController, AVPlayerViewControllerDelegate
{
    var records: [Content]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.tableView.contentInset = UIEdgeInsetsMake(CGFloat(NavigationTabBar.height), 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.records = try! CoreDataManager.shared.managedContext.fetch(Content.fetchRequest())
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.records?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContentTableViewCell
        
        cell.prepareCell(forContent: records![indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if records?[indexPath.row].typeID == 1 {
            let playerViewController = AVPlayerViewController()
            playerViewController.player = AVPlayer(url: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(records![indexPath.row].resourceURL!))
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        } else if records![indexPath.row].typeID == 0 {
            let photo = PhotoInfo(image: UIImage(contentsOfFile: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(records![indexPath.row].resourceURL!).path)!)
            let controller = NYTPhotosViewController(photos: [photo])
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: " Delete") { (action, indexPath) in
            if let row = self.records?.remove(at: indexPath.row) {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                CoreDataManager.shared.managedContext.delete(row)
                try! FileManager.default.removeItem(at: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(row.resourceURL!))
                CoreDataManager.shared.saveContext()
            }
        }
        
        let edit = UITableViewRowAction(style: .normal, title: " Edit     ") { (action, indexPath) in
            print("Edit is not implemented yet...")
        }
        
        edit.backgroundColor = UIColor(red: 0.0, green: 191/255.0, blue: 1.0, alpha: 1.0)
        
        return [delete, edit]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "header")
        return cell?.contentView
    }
}
