//
//  NewContentPageViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class NewContentViewController: UIPageViewController, UIImagePickerControllerDelegate
{
    private let contentType: ContentType
    let saveContentVC: SaveContentViewController
    var captureContentVC: CameraContentController?
    
    init(forContentType type: ContentType) {
        self.contentType = type
        self.saveContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saveNewContent") as! SaveContentViewController
        self.saveContentVC.view.tag = 0
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        self.saveContentVC.contentController = self
        
        switch type {
        case .Picture:
            captureContentVC = CameraContentController(for: self, withCameraMode: .photo)
        default:
            print("Type is not supported yet")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTakePicture(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        self.saveContentVC.fillContentPreview(withView: imageView)
        self.setViewControllers([saveContentVC], direction: .forward, animated: true, completion: nil)
    }
    
    func didTakeVideo(_ videoURL: URL) {
        self.setViewControllers([saveContentVC], direction: .forward, animated: true, completion: nil)
    }
}
