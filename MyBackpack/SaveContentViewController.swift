//
//  SaveContentViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import AVFoundation

class SaveContentViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTitleTextField: UITextField!
    @IBOutlet weak var contentPreviewView: UIView!
    @IBOutlet weak var lectureDropDownList: IQDropDownTextField!

    var contentController: NewContentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentTitleTextField.delegate = self
        
        contentPreviewView.backgroundColor = UIColor.clear
        self.lectureDropDownList.isOptionalDropDown = false
        self.lectureDropDownList.itemList = ["Lecture 5", "Lecture 4", "Lecture 3", "Lecture 2", "Lecture 1"]
        self.lectureDropDownList.inputView?.backgroundColor = .white
        
        self.setupPickerToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let contentType = self.contentController?.captureContentVC?.providedContentType,
            let resourse = self.contentController?.captureContentVC?.resource
        {
            switch contentType {
            case .Picture:
                preview(image: resourse as! UIImage)
            case .Video:
                let asset = AVAsset(url: resourse as! URL)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try! imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                preview(image: UIImage(cgImage: cgImage))
            default:
                print("Oops")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.contentTitleTextField.isEditing {
            self.contentTitleTextField.endEditing(true)
        } else if self.lectureDropDownList.isEditing {
            self.lectureDropDownList.endEditing(true)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        if let parent = self.contentController {
            parent.captureContentVC?.presentAnimated(inScrollDirection: .reverse)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        if let parent = self.contentController {
            parent.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentTitleTextField.resignFirstResponder()
        return true
    }
    
    private func setupPickerToolbar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .blue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton, spaceButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        lectureDropDownList.inputAccessoryView = toolBar
    }
    
    @objc private func donePicker() {
        self.lectureDropDownList.endEditing(true)
    }
    
    private func preview(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        self.contentPreviewView.addSubview(imageView)
        self.contentPreviewView.addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        self.contentPreviewView.addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
    }
}
