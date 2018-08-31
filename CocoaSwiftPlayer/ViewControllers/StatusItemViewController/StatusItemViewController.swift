//
//  StatusItemViewController.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 17/2/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Cocoa

class StatusItemViewController: PlayerViewController {

    // ========================
    // MARK: - Static functions
    // ========================
    
    class func loadFromNib() -> StatusItemViewController {
        let vc = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StatusItemViewController")) as! StatusItemViewController
        return vc
    }

    // =========================
    // MARK: - Lifecycle methods
    // =========================

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let manager = PlayerManager.sharedManager
        volumeSlider.floatValue = manager.volume
        if manager.isPlaying {
            songTitleLabel.stringValue = manager.currentSong!.title
            timeLabel.stringValue = manager.songProgressText
        }
    }
    
}
