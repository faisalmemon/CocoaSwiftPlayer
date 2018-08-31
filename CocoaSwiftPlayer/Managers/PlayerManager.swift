//
//  PlayerManager.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 3/2/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Cocoa
import AVFoundation
import RealmSwift

class PlayerManager: NSObject, AVAudioPlayerDelegate {
    
    static var sharedManager = PlayerManager()
    
    var statusItem: NSStatusItem?
    
    var isPlaying: Bool {
        if let player = player {
            return player.isPlaying
        } else {
            return false
        }
    }
    
    var player: AVAudioPlayer?
    
    var currentIndex: Int?
    var currentSong: Song? = nil {
        didSet {
            if let currentSong = currentSong {
                currentIndex = currentPlayList.index(where: { song -> Bool in
                    return song.location == currentSong.location
                })
                
                if currentSong.location != player?.url?.path {
                    player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: currentSong.location))
                    player?.volume = volume
                }
                
                songTimer = nil
                songProgress = 0
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.ChangeSong), object: self, userInfo: [Constants.NotificationUserInfos.Song: currentSong])
            } else {
                stop()
                player = nil
            }
        }
    }
    // The currently using list
    var currentPlayList: [Song] = []
    // Made of default playlist
    var shufflePlayList: [Song] = []
    // Default Playlist
    var playList: [Song] = [] {
        didSet {
            if !isShuffle {
                currentPlayList = playList
            }
        }
    }
    
    var isRepeated = false {
        didSet {
            print("isRepeat: \(isRepeated)")
        }
    }
    var isShuffle = false {
        didSet {
            print("isShuffle: \(isShuffle)")
            if isShuffle {
                if let currentSong = currentSong {
                    let list = playList.filter { song -> Bool in
                        return song.location != currentSong.location
                    }
                    shufflePlayList = [currentSong] + list.shuffle()
                } else {
                    shufflePlayList = playList.shuffle()
                }
                currentPlayList = shufflePlayList
            } else {
                currentPlayList = playList
            }
        }
    }
    var volume: Float = 0.5 {
        didSet {
            player?.volume = volume
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.VolumeChanged), object: self)
        }
    }
    
    var songTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    var songProgress: Double = 0
    var songProgressText: String {
        get {
            return "\(timeFormatter.string(from: songProgress)!)"
        }
    }
    lazy var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    // MARK: - Lifecycle Methods
    
    override init() {
        super.init()
    }
    
    deinit {
        
    }
    
    // MARK: - Player Control
    
    func play() {
        if isPlaying {
            pause()
            return
        }
        
        if currentPlayList.isEmpty {
            loadAllSongs()
        }
        
        if currentSong == nil {
            currentSong = currentPlayList[0]
        }
        
        player?.play()
        
        songTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerManager.updateProgress), userInfo: nil, repeats: true)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.StartPlaying), object: self, userInfo: [Constants.NotificationUserInfos.Song: currentSong!])
    }
    
    func pause() {
        player?.pause()
        
        songTimer = nil
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.PausePlaying), object: self, userInfo: [Constants.NotificationUserInfos.Song: currentSong!])
    }
    
    func stop() {
        player?.stop()
    }
    
    func next() {
        guard let currentIndex = currentIndex else { return }
        
        if !isRepeated && currentIndex == currentPlayList.count - 1 {
            currentSong = nil
        } else if isRepeated && currentIndex == currentPlayList.count - 1 {
            currentSong = currentPlayList.first
            play()
        } else {
            currentSong = currentPlayList[currentIndex + 1]
            play()
        }
    }
    
    func rewind() {
        guard let currentIndex = currentIndex else { return }
        
        if !isRepeated && currentIndex == 0 {
            currentSong = nil
        } else if isRepeated && currentIndex == 0 {
            currentSong = currentPlayList.last
            play()
        } else {
            currentSong = currentPlayList[currentIndex - 1]
            play()
        }
    }
    
    fileprivate func loadAllSongs() {
        let realm = try! Realm()
        playList = realm.objects(Song).map { song in return song}
    }
    
    // MARK: - NSTimer
    
    func updateProgress() {
        songProgress += 1
        statusItem?.button?.title = songProgressText
    }

}
