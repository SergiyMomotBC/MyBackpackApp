//
//  RemidersFilterViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/21/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class RemindersFilterViewController: UIViewController 
{
    var searchController: SearchController?
    
    var filterOptions: ReminderFilterOptionsViewController {
        return self.childViewControllers.first! as! ReminderFilterOptionsViewController
    }

    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true) {
            self.searchController?.sendSearchEvent()
        }
    }
    
    @IBAction func clearOptions(_ sender: Any) {
        filterOptions.reset()
    }
}
