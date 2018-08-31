//
//  EventMonitor.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 17/2/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Cocoa

final public class EventMonitor {
    fileprivate var monitor: AnyObject?
    fileprivate let mask: NSEventMask
    fileprivate let handler: (NSEvent?) -> ()
    
    public init(mask: NSEventMask, handler: @escaping (NSEvent?) -> ()) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject
    }
    
    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
