//
//  PlaylistViewController.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 12/2/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Cocoa
import RealmSwift

class PlaylistViewController: NSViewController {
    
    var playlists = [Playlist]() {
        didSet {
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true)
        }
    }

    @IBOutlet weak var outlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("PlaylistViewController viewDidLoad")
        
        outlineView.dataSource = self
        outlineView.delegate = self
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(PlaylistViewController.deletePlaylist(_:)), keyEquivalent: ""))
        outlineView.menu = menu
        
        let realm = try! Realm()
        playlists = realm.objects(Playlist.self).map { playlist in return playlist }
        
        outlineView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
    }
    
    @IBAction func addPlaylist(_ sender: AnyObject) {
        let playlist = Playlist()
        let realm = try! Realm()
        try! realm.write {
            realm.add(playlist)
        }
        
        playlists.append(playlist)
    }
    
    @objc func deletePlaylist(_ sender: AnyObject) {
        let playlist = playlists[outlineView.clickedRow - 1]
        playlists.remove(at: outlineView.clickedRow - 1)
        outlineView.reloadData()
        
        playlist.delete()
    }
    
    // MARK: - Helper
    
    func isHeader(_ item: AnyObject) -> Bool {
        return item is String
    }
    
}

extension PlaylistViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 1
        } else {
            return playlists.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return isHeader(item as AnyObject)
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return "Library"
        } else {
            return playlists[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return item
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        let canDrag = item is Playlist && index < 0
        
        if canDrag {
            return .move
        } else {
            return NSDragOperation()
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        guard let playlist = item as? Playlist else { return false }
        
        let pb = info.draggingPasteboard()
        let location = pb.string(forType: NSPasteboard.PasteboardType.string)
        
        let realm = try! Realm()
        if let location = location {
            if let song = realm.objects(Song.self).filter("location = '\(location)'").first {
                let index = playlist.songs.index { s in
                    return s.location == song.location
                }
                if index == nil {
                    try! realm.write {
                        playlist.songs.append(song)
                    }
                    outlineView.reloadData()
                }
            }
            return true
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if isHeader(item as AnyObject) {
            return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self)
        } else {
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? CustomTableCellView
            if let playlist = item as? Playlist {
                view?.textField?.stringValue = "\(playlist.name)"
                view?.textField?.delegate = self
                view?.songCount.stringValue = "(\(playlist.songs.count))"
            }
            return view
        }
    }
    
}

extension PlaylistViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return !isHeader(item as AnyObject)
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return false
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let playlist = playlists[outlineView.selectedRow - 1]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.SwitchPlaylist), object: self, userInfo: [Constants.NotificationUserInfos.Playlist: playlist])
    }
    
}

extension PlaylistViewController: NSTextFieldDelegate {
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            print(textField.stringValue)
            let row = outlineView.row(for: textField)
            let playlist = playlists[row - 1]
            
            let realm = try! Realm()
            try! realm.write {
                playlist.name = textField.stringValue
            }
        }
    }
    
}
