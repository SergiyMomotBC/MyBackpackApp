//
//  NewContentPageViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class NewContentViewController: UIPageViewController
{
    private let contentType: ContentType
    private let saveContentVC: SaveContentViewController
    var captureContentVC: ContentProvider?
    
    init(forContentType type: ContentType) {
        self.contentType = type
        self.saveContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saveNewContent") as! SaveContentViewController
        self.saveContentVC.view.tag = 0
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.saveContentVC.contentController = self
        
        switch type {
        case .Picture:
            captureContentVC = CameraContentController(for: self, withCameraMode: .photo)
        case .Video:
            captureContentVC = CameraContentController(for: self, withCameraMode: .video)
        case .Audio:
            captureContentVC = AudioRecorderController(for: self)
        case .Note:
            captureContentVC = TakeNoteController(for: self)
        }
        
        captureContentVC!.presentAnimated(inScrollDirection: .forward)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contentProviderDidSuccesfullyFinished() {
        if let resource = self.captureContentVC?.resource, let type = self.captureContentVC?.providedContentType {
            self.saveContentVC.resourceType = type
            self.saveContentVC.resource = resource
            self.setViewControllers([saveContentVC], direction: .forward, animated: true, completion: nil)
        }
    }
}
