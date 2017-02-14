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
    
    @IBOutlet weak var addCloseBarButton: UIBarButtonItem!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet var menuView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pictureController = CameraController(forViewController: self)
    }

    @IBAction func openCamera(_ sender: Any) {
        self.pictureController?.presentImagePicker()
    }
    
    @IBAction func showMenu( _ sender: UIBarButtonItem) {
        
        if(self.menuView.superview == nil) {
            self.view.addSubview(self.menuView)
            self.menuView.center.y = -self.menuView.bounds.height / 2

            let viewsDictionary = ["stackView": self.menuView]
            
            let stackView_H = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[stackView]-0-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: viewsDictionary)
            
            let stackView_V = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[stackView(300)]|",
                options: NSLayoutFormatOptions(rawValue:0),
                metrics: nil,
                views: viewsDictionary)
            
            view.addConstraints(stackView_H)
            view.addConstraints(stackView_V)
        }
        
        UIView.animate(withDuration: 0.12, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            () -> Void in
            if self.menuView.center.y < 0 {
                self.menuView.center.y = self.menuView.bounds.height / 2 + 1
                self.blurEffect.alpha = 1.0
                
            } else {
                self.menuView.center.y = -self.menuView.bounds.height / 2
                self.blurEffect.alpha = 0.0
            }
        }, completion: { success in
            if self.menuView.center.y < 0 {
                self.menuView.removeFromSuperview()
                let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.showMenu))
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
            } else {
                let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(self.showMenu))
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = barButton
            }
        })

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveRecord" {
            let vc = segue.destination as! ImageSaveViewController
            vc.sourceImage = self.pictureController?.takenImage ?? nil
        }
    }

}

