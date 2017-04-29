//
//  NewClassViewControllerDelegate.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/21/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation

protocol ClassViewControllerDelegate: class {
    func classViewController(_ classVC: UIViewController, didCommitChanges success: Bool)
}
