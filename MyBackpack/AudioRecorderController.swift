//
//  AudioRecorderController.swift
//   
//
//  Created by Sergiy Momot on 2/24/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class AudioRecorderController: NSObject, ContentProvider, IQAudioRecorderViewControllerDelegate
{
    private var recordedAudioURL: URL?
    private var audioRecorderVC: IQAudioRecorderViewController

    init(for parent: NewContentViewController) {
        self.parentVC = parent
        self.audioRecorderVC = IQAudioRecorderViewController()
        
        super.init()
        
        self.audioRecorderVC.delegate = self
        self.audioRecorderVC.maximumRecordDuration = 3600
        self.audioRecorderVC.title = "Voice Recording"
        self.audioRecorderVC.allowCropping = false
        self.audioRecorderVC.normalTintColor = .white
        self.audioRecorderVC.highlightedTintColor = UIColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 1.0)
        self.audioRecorderVC.barStyle = .default
    }
    
    // MARK: Conforming to ContentProvider protocol
    
    weak var parentVC: NewContentViewController?
    
    var providedContentType: ContentType {
        return ContentType.Audio
    }
    
    var resource: AnyObject? {
        return self.recordedAudioURL as AnyObject?
    }
    
    func presentAnimated(inScrollDirection direction: UIPageViewControllerNavigationDirection) {
        let nc = UINavigationController(rootViewController: self.audioRecorderVC)
        
        nc.isToolbarHidden = false
        nc.toolbar.isTranslucent = true
        nc.navigationBar.isTranslucent = true
        self.audioRecorderVC.barStyle = self.audioRecorderVC.barStyle
        
        self.parentVC?.setViewControllers([nc], direction: direction, animated: true, completion: nil)
    }
    
    // MARK: Conforming to IQAudioRecorderViewControllerDelegate protocol
    
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        self.recordedAudioURL = URL(fileURLWithPath: filePath)
        self.parentVC?.contentProviderDidSuccesfullyFinished()
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        self.parentVC?.dismiss(animated: true, completion: nil)
    }
}
