//
//  Song.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 31/1/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Cocoa
import iTunesLibrary
import RealmSwift

class Song: Object {
    
    static let formatter = DateComponentsFormatter()

    @objc dynamic var title: String = ""
    @objc dynamic var location: String = ""
    @objc dynamic var album: String = ""
    @objc dynamic var length: Double = 0.0
    @objc dynamic var artist: String = ""
    @objc dynamic var playCount: Int = 0
    
    @objc dynamic var lengthText: String {
        get {
            return Song.formatter.string(from: length)!
        }
    }
    
    convenience init(item: ITLibMediaItem) {
        self.init()
        self.title = item.title
        if item.artist?.name != nil {
            self.artist = (item.artist?.name!)!
        }
        self.location = item.location?.path ?? ""
        self.length = TimeInterval(item.totalTime) / 1000.0
    }
    
    override static func ignoredProperties() -> [String] {
        return ["lengthText"]
    }
    
    func delete() {
        try! realm?.write {
            realm?.delete(self)
        }
    }
    
}
