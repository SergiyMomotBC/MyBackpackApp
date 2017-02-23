//
//  SaveContentViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class SaveContentViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTitleTextField: UITextField!
    @IBOutlet weak var contentPreviewView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var contentController: NewContentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentPreviewView.backgroundColor = UIColor.clear
    }
    
    func fillContentPreview(withView aView: UIView) {
        self.contentPreviewView.addSubview(aView)
        self.contentPreviewView.addConstraintsWithFormat(format: "H:|[v0]|", views: aView)
        self.contentPreviewView.addConstraintsWithFormat(format: "V:|[v0]|", views: aView)
    }
}
