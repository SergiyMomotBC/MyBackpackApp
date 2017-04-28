//
//  NoClassesViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/28/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class NoClassesViewController: UIViewController, ClassViewControllerDelegate
{
    @IBAction func createFirstClass(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "newClass") as! NewClassViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func classViewController(_ classVC: UIViewController, didCommitChanges success: Bool) {
        classVC.dismiss(animated: true, completion: nil)
        
        if success && UIApplication.shared.keyWindow!.rootViewController! == self {
            UIApplication.shared.keyWindow!.rootViewController = self.storyboard!.instantiateViewController(withIdentifier: "root")
        }
    }
}
