//
//  PictureController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/13/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices

class CameraController: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    private let imagePicker: UIImagePickerController!
    private(set) var takenImage: UIImage?
    private let sourceViewController: UIViewController
    
    init(forViewController vc: UIViewController) {
        self.imagePicker = UIImagePickerController()
        self.sourceViewController = vc
        
        super.init()
        
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .camera
        self.imagePicker.mediaTypes = [kUTTypeMovie as String]
        self.imagePicker.cameraCaptureMode = .video
        self.imagePicker.videoMaximumDuration = 60
        self.imagePicker.modalPresentationStyle = .fullScreen
    }
    
    func presentImagePicker() {
        self.sourceViewController.present(self.imagePicker, animated: true, completion: nil)
    }
    
    //MARK: conforming to UIImagePickerControllerDelegate protocol
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.takenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.sourceViewController.dismiss(animated: true, completion: nil)
        self.sourceViewController.performSegue(withIdentifier: "saveRecord", sender: self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.sourceViewController.dismiss(animated: true, completion: nil)
    }
}
