//
//  ViewController.swift
//  MyBackpack
//
//  Created by Sergiy Momot on 2/7/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    var pictureController: CameraController?
    var menuController: MenuController!
    var navigationTabBar: NavigationTabBar!
    
    @IBOutlet weak var addCloseBarButton: UIBarButtonItem!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet var menuView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.pictureController = CameraController(forViewController: self)
        
        self.menuController = MenuController(withStackView: self.menuView, inViewController: self, withYOffset: 40)
        self.navigationTabBar = NavigationTabBar(frame: .zero, forViewController: self)
    }

    @IBAction func openCamera(_ sender: Any) {
        self.pictureController?.presentImagePicker()
    }
    
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        if !self.menuController.isShowing {
            self.menuController.show { success in
                let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(self.showMenu))
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
            }
        } else {
            self.menuController.hide { success in
                let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.showMenu))
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveRecord" {
            let vc = segue.destination as! ImageSaveViewController
            vc.sourceImage = self.pictureController?.takenImage ?? nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.menuController.isShowing {
            self.menuController.hide { success in
                let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.showMenu))
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
            }
        }
    }
}
