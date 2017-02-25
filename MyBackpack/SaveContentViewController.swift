//
//  SaveContentViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import AVFoundation

class SaveContentViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTitleTextField: UITextField!
    @IBOutlet weak var contentPreviewView: UIView!

    var contentController: NewContentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentPreviewView.backgroundColor = UIColor.clear
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

    private func preview(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        self.contentPreviewView.addSubview(imageView)
        self.contentPreviewView.addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        self.contentPreviewView.addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
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
}
