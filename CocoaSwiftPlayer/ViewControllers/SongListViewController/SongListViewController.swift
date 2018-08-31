//
//  SongListViewController.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 5/2/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Cocoa
import RealmSwift

class SongListViewController: NSViewController {
    
    dynamic var songs: [Song] = []

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("SongListViewController viewDidLoad")
        
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "APP_LAUNCHED") {
            let songManager = SongManager()
            try! songManager.importSongs()
            defaults.set(true, forKey: "APP_LAUNCHED")
        }
        
        let realm = try! Realm()
        let result = realm.objects(Song)
        songs = result.map { song in
            return song
        }
        
        tableView.doubleAction = #selector(SongListViewController.doubleClick(_:))
        
        tableView.dataSource = self
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(SongListViewController.deleteSongs(_:)), keyEquivalent: ""))
        tableView.menu = menu
        
        NotificationCenter.default.addObserver(self, selector: #selector(SongListViewController.changeSong(_:)), name: NSNotification.Name(rawValue: Constants.Notifications.ChangeSong), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SongListViewController.switchPlaylist(_:)), name: NSNotification.Name(rawValue: Constants.Notifications.SwitchPlaylist), object: nil)
    }
    
    func doubleClick(_ sender: NSTableView) {
        let manager = PlayerManager.sharedManager
        if tableView.selectedRow != -1 {
            manager.currentPlayList = songs
            manager.currentSong = songs[tableView.selectedRow]
        }
        manager.play()
    }
    
    func deleteSongs(_ sender: AnyObject) {
        let songsMutableArray = NSMutableArray(array: songs)
        let toBeDeletedSongs = songsMutableArray.objects(at: tableView.selectedRowIndexes) as? [Song]
        songsMutableArray.removeObjects(at: tableView.selectedRowIndexes)
        
        if let mutableArray = songsMutableArray as AnyObject as? [Song] {
            songs = mutableArray
            tableView.reloadData()
        }
        
        if let songs = toBeDeletedSongs {
            for song in songs {
                song.delete()
            }
        }
    }
    
    // MARK: - Notification
    
    func changeSong(_ notification: Notification) {
        guard let song = notification.userInfo?[Constants.NotificationUserInfos.Song] as? Song else { return }
        
        let index = songs.index { s in
            return s.location == song.location
        }
        
        if let index = index {
            tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            tableView.scrollRowToVisible(index)
        }
    }
    
    func switchPlaylist(_ notification: Notification) {
        guard let playlist = notification.userInfo?[Constants.NotificationUserInfos.Playlist] as? Playlist else { return }
        
        songs = playlist.songs.map { song in return song }
        tableView.reloadData()
    }
    
}

extension SongListViewController: NSTableViewDataSource {
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let song = songs[row]
        
        let pbItem = NSPasteboardItem()
        pbItem.setString(song.location, forType: NSPasteboardTypeString)
        return pbItem
    }
    
}
