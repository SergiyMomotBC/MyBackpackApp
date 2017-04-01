//
//  SearchingEngine.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/31/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class SearchingEngine: NSObject, UITableViewDataSource
{
    var resultData: [[Content]] = []
    
    func updateDataForSearchString(_ text: String) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContentTableViewCell
        
        cell.prepareCell(forContent: resultData[indexPath.section][indexPath.row])
        
        return cell
    }
    
    
}
