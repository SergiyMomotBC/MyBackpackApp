//
//  TakePictureViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import MobileCoreServices

class CameraContentController: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    private let parentVC: NewContentViewController
    private let imagePicker: UIImagePickerController
    
    init(for parent: NewContentViewController, withCameraMode captureMode: UIImagePickerControllerCameraCaptureMode) {
        self.parentVC = parent
        self.imagePicker = UIImagePickerController()
        
        super.init()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.cameraFlashMode = .off
        
        
        if captureMode == .photo {
            imagePicker.cameraCaptureMode = .photo
        } else {
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.cameraCaptureMode = .video
            imagePicker.videoQuality = .typeMedium
            imagePicker.videoMaximumDuration = 120
        }
        
        self.parentVC.setViewControllers([self.imagePicker], direction: .forward, animated: false, completion: nil)
    }
    
    // MARK: Conforming to UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if self.imagePicker.cameraCaptureMode == .photo {
            if let takenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.parentVC.didTakePicture(takenImage)
            }
        } else {
            if let takenVideoURL = info[UIImagePickerControllerMediaURL] as? URL {
                self.parentVC.didTakeVideo(takenVideoURL)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.parentVC.dismiss(animated: true, completion: nil)
    }
}
