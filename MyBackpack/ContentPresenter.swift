//
//  ContentPresenter.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/10/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import UIKit
import NYTPhotoViewer
import AVKit
import Jukebox

class ContentPresenter
{
    private var noteController: UIViewController!
    
    func presentContent(_ content: Content, inViewController vc: UIViewController) {
        if let contentType = ContentType(rawValue: Int(content.typeID)) {
            switch contentType {
            case .Audio:
                let audioURL = ContentFileManager.shared.documentsFolderURL.appendingPathComponent(content.resourceURL)
                self.presentAudio(url: audioURL, in: vc)
            case .Video:
                let videoURL = ContentFileManager.shared.documentsFolderURL.appendingPathComponent(content.resourceURL)
                self.presentVideo(url: videoURL, in: vc)
            case .Note:
                let noteText = try! Data(contentsOf: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(content.resourceURL))
                self.presentNote(data: noteText, in: vc)
            case .Picture:
                let photo = UIImage(contentsOfFile: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(content.resourceURL).path)
                self.presentImage(photo!, in: vc)
            }
        }
    } 
    
    private func presentVideo(url: URL, in vc: UIViewController) {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = AVPlayer(url: url)
        vc.present(playerViewController, animated: true, completion: { playerViewController.player?.play() })
    }
    
    private func presentImage(_ image: UIImage, in vc: UIViewController) {
        let photo = PhotoInfo(image: image)
        let controller = NYTPhotosViewController(photos: [photo])
        vc.present(controller, animated: true, completion: nil)
    }
    
    private func presentNote(data: Data, in vc: UIViewController) {
        let noteViewerController = UIViewController()
        noteViewerController.view.backgroundColor = .white
        let editorView = UITextView()
        editorView.autocorrectionType = .no
        editorView.backgroundColor = .white
        editorView.attributedText = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        editorView.isEditable = false
        noteViewerController.view.addSubview(editorView)
        noteViewerController.view.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: editorView)
        noteViewerController.view.addConstraintsWithFormat(format: "V:|-4-[v0]-4-|", views: editorView)
        
        let navigationVC = UINavigationController(rootViewController: noteViewerController)
        navigationVC.navigationBar.topItem?.title = "Note"
        navigationVC.navigationBar.barTintColor = UIColor(red: 128/255.0, green: 0/255.0, blue: 64/255.0, alpha: 1.0)
        navigationVC.navigationBar.tintColor = .white
        navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationVC.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        
        self.noteController = navigationVC
        
        vc.present(navigationVC, animated: true, completion: nil)
    }
    
    private func presentAudio(url: URL, in vc: UIViewController) {
        let musicController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "jukebox") as! MusicViewController
        musicController.jukebox = Jukebox(delegate: musicController, items: [JukeboxItem(URL: url)])
        musicController.view.backgroundColor = .clear
        musicController.centerContainer.backgroundColor = .white
        
        let navigationVC = UINavigationController(rootViewController: musicController)
        navigationVC.navigationBar.topItem?.title = "Voice Recording"
        navigationVC.navigationBar.barTintColor = UIColor(red: 128/255.0, green: 0/255.0, blue: 64/255.0, alpha: 1.0)
        navigationVC.navigationBar.tintColor = .white
        navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationVC.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        
        self.noteController = navigationVC
        
        vc.present(navigationVC, animated: true) {
            musicController.playPauseAction()
        }
    }
    
    @objc private func done() {
        self.noteController.dismiss(animated: true, completion: nil)
        self.noteController = nil
    }
}
