//
//  PlayerViewController.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 3/2/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Cocoa

class PlayerViewController: NSViewController {

    @IBOutlet weak var playButton: NSButton!
    
    @IBOutlet weak var rewindButton: NSButton!
    
    @IBOutlet weak var nextButton: NSButton!
    
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBOutlet weak var timeLabel: NSTextField!
    
    @IBOutlet weak var shuffleButton: NSButton!
    
    @IBOutlet weak var repeatButton: NSButton!
    
    @IBOutlet weak var songTitleLabel: NSTextField!
    
    let manager = PlayerManager.sharedManager
    
    var songTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.changeSong(_:)), name: NSNotification.Name(rawValue: Constants.Notifications.ChangeSong), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.volumeChanged(_:)), name: NSNotification.Name(rawValue: Constants.Notifications.VolumeChanged), object: nil)
        
        songTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerViewController.updateProgress), userInfo: nil, repeats: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func play(_ sender: NSButton) {
        manager.play()
    }
    
    @IBAction func rewind(_ sender: NSButton) {
        manager.rewind()
    }
    
    @IBAction func slideVolume(_ sender: NSSlider) {
        manager.volume = sender.floatValue
    }
    
    @IBAction func next(_ sender: NSButton) {
        manager.next()
    }
    
    @IBAction func shuffle(_ sender: NSButton) {
        manager.isShuffle = !manager.isShuffle
    }
    
    @IBAction func repeatPlaylist(_ sender: NSButton) {
        manager.isRepeated = !manager.isRepeated
        
    }
    
    // MARK: - Helpers
    
    func changeSong(_ notification: Notification) {
        guard let song = notification.userInfo?[Constants.NotificationUserInfos.Song] as? Song else { return }
        
        timeLabel.stringValue = "0:00"
        
        songTitleLabel.stringValue = song.title
    }
    
    func volumeChanged(_ notification: Notification) {
        volumeSlider.floatValue = manager.volume
    }

    func updateProgress() {
        timeLabel.stringValue = manager.songProgressText
    }
    
}
