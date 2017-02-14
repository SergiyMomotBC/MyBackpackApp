//
//  ImageSaveViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/12/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class ImageSaveViewController: UIViewController {

    var sourceImage: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.enableSlideWithKeyboard()
        
        if let image = sourceImage {
            self.imageView.image = image
        }
    }
    
    
    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
