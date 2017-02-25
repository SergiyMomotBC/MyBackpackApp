//
//  TakePictureViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import MobileCoreServices

class CameraContentController: NSObject, ContentProvider, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    private var imagePicker: UIImagePickerController!
    private let captureMode: UIImagePickerControllerCameraCaptureMode
    private var takenImage: UIImage?
    private var takenVideoURL: URL?
    
    init(for parent: NewContentViewController, withCameraMode captureMode: UIImagePickerControllerCameraCaptureMode) {
        self.parentVC = parent
        self.captureMode = captureMode
        
        super.init()
    }
    
    private func prepareImagePicker() {
        self.imagePicker = UIImagePickerController()
    
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
    }
    
    // MARK: Conforming to ContentProvider protocol
    
    var parentVC: NewContentViewController
    
    var providedContentType: ContentType {
        return captureMode == .photo ? ContentType.Picture : ContentType.Video
    }
    
    var resource: AnyObject? {
        return captureMode == .photo ? self.takenImage as AnyObject?: self.takenVideoURL as AnyObject?
    }
    
    func presentAnimated(inScrollDirection direction: UIPageViewControllerNavigationDirection) {
        self.prepareImagePicker()
        self.parentVC.setViewControllers([self.imagePicker], direction: direction, animated: true, completion: nil)
    }
    
    // MARK: Conforming to UIImagePickerControllerDelegate protocol
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if self.imagePicker.cameraCaptureMode == .photo {
            self.takenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            if self.takenImage != nil {
                self.parentVC.contentProviderDidSuccesfullyFinished()
            }
        } else {
            self.takenVideoURL = info[UIImagePickerControllerMediaURL] as? URL
            if self.takenVideoURL != nil {
                self.parentVC.contentProviderDidSuccesfullyFinished()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.parentVC.dismiss(animated: true, completion: nil)
    }
}
