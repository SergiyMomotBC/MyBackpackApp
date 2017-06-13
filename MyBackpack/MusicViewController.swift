//
//  ViewController.swift
//  Jukebox-Demo
//
//  Created by Teodor Patras on 27/08/15.
//  Copyright (c) 2015 Teodor Patras. All rights reserved.
//

import UIKit
import Jukebox

class MusicViewController: UIViewController, JukeboxDelegate
{
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var centerContainer: UIView!
    
    var jukebox : Jukebox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        jukebox.volume = AVAudioSession.sharedInstance().outputVolume
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopAction()
    }
    
    func configureUI() {
        resetUI()
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())
        view.backgroundColor = UIColor.clear
    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
            if currentTime == duration {
                stopAction()
                return
            }
            
            let value = Float(currentTime / duration)
            slider.value = value
            populateLabelWithTime(currentTimeLabel, time: currentTime)
            populateLabelWithTime(durationLabel, time: duration)
        } else {
            resetUI()
        }
    }
    
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.playPauseButton.alpha = jukebox.state == .loading ? 0 : 1
            self.playPauseButton.isEnabled = jukebox.state == .loading ? false : true
        })
        
        if jukebox.state == .ready {
            playPauseButton.setImage(UIImage(named: "playBtn"), for: UIControlState())
        } else if jukebox.state == .loading  {
            playPauseButton.setImage(UIImage(named: "pauseBtn"), for: UIControlState())
        } else {
            let imageName: String
            switch jukebox.state {
            case .playing, .loading:
                imageName = "pauseBtn"
            case .paused, .failed, .ready:
                imageName = "playBtn"
            }
            playPauseButton.setImage(UIImage(named: imageName), for: UIControlState())
        }
    }
    
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {}
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {}
 
    @IBAction func progressSliderValueChanged() {
        if let duration = jukebox.currentItem?.meta.duration {
            jukebox.seek(toSecond: Int(Double(slider.value) * duration))
        }
    }
    
    @IBAction func playPauseAction() {
        switch jukebox.state {
            case .ready :
                jukebox.play(atIndex: 0)
            case .playing :
                jukebox.pause()
            case .paused :
                jukebox.play()
            default:
                jukebox.stop()
        }
    }
    
    @IBAction func replayAction() {
        resetUI()
        jukebox.stop()
        jukebox.play()
    }
    
    @IBAction func stopAction() {
        resetUI()
        jukebox.stop()
    }
    
    func populateLabelWithTime(_ label : UILabel, time: Double) {
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        
        label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    func resetUI() {
        durationLabel.text = "00:00"
        currentTimeLabel.text = "00:00"
        slider.value = 0
    }
}

