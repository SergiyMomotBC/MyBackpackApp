//
//  ContentPreviewer.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/3/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import RichEditorView
import Jukebox

class ContentPreviewer
{
    private let contentType: ContentType
    private let resource: AnyObject
    private let view: UIView
    
    private var videoPlayer: AVPlayer!
    private var playPauseButton: UIButton!
    private var isPlaying = false
    
    private var musicController: MusicViewController!
    
    init(forContentType type: ContentType, withResource resource: AnyObject, inView view: UIView) {
        self.contentType = type
        self.resource = resource
        self.view = view
    }
    
    func preparePreview() {
        
        switch contentType {
        case .Picture:
            self.previewImage(image: resource as! UIImage)
        case .Video:
            self.previewVideo(url: resource as! URL)
        case .Audio:
            self.previewAudio(url: resource as! URL)
        case .Note:
            self.previewNote(string: resource as! String)
        }
    }
    
    private func previewNote(string note: String) {
        let editorView = RichEditorView(frame: CGRect(x: 10, y: 2, width: self.view.frame.width - 20, height: self.view.frame.height - 7))
        editorView.backgroundColor = UIColor.white
        editorView.clipsToBounds = true
        editorView.isEditingEnabled = false
        editorView.html = note
        self.view.addSubview(editorView)
        
        self.view.backgroundColor = UIColor.white
        self.view.layer.cornerRadius = 10
    }
    
    private func previewImage(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        self.view.addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        self.view.addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
    }
    
    private func previewAudio(url: URL) {
        musicController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "jukebox") as! MusicViewController
        musicController.jukebox = Jukebox(delegate: musicController, items: [JukeboxItem(URL: url)])
        self.view.addSubview(musicController.view)
        self.view.addConstraintsWithFormat(format: "H:|[v0]|", views: musicController.view)
        self.view.addConstraintsWithFormat(format: "V:|[v0]|", views: musicController.view)
        self.musicController.view.backgroundColor = .clear
        self.musicController.centerContainer.backgroundColor = .white
        self.musicController.centerContainer.layer.cornerRadius = 10
    }
    
    private func previewVideo(url: URL) {
        self.videoPlayer = AVPlayer(url: url)
        videoPlayer.actionAtItemEnd = .none
        
        let videoLayer = AVPlayerLayer(player: videoPlayer)
        videoLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspect
        videoPlayer.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
        self.view.layer.addSublayer(videoLayer)
        
        self.playPauseButton = UIButton(frame: .zero)
        playPauseButton.frame.size = CGSize(width: 80, height: 80)
        playPauseButton.contentVerticalAlignment = .fill
        playPauseButton.contentHorizontalAlignment = .fill
        playPauseButton.alpha = 0.75
        playPauseButton.setImage(UIImage(named: "videoPlayButton"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        view.addSubview(playPauseButton)
        playPauseButton.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
    }
    
    @objc private func playVideo() {
        if !isPlaying {
            self.videoPlayer.play()
            self.playPauseButton.alpha = 0.1
            isPlaying = true
            NotificationCenter.default.addObserver(self, selector: #selector(playVideo), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
        } else {
            self.videoPlayer.pause()
            self.videoPlayer.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
            self.playPauseButton.alpha = 0.75
            isPlaying = false
            NotificationCenter.default.removeObserver(self)
        }
    }
}
