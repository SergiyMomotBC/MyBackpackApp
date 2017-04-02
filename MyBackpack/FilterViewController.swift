//
//  FilterViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/1/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    @IBOutlet weak var optionsView: UIView!
    
    var searchController: SearchController?
    
    var filterOptions: FilterOptionsViewController {
        return self.childViewControllers.first! as! FilterOptionsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true) {
            self.searchController?.updateSearch()
        }
    }
    
    @IBAction func clearOptions(_ sender: Any) {
        filterOptions.reset()
    }
}
