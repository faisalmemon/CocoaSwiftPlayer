//
//  AppDelegate.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 30/1/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var windowController: MainWindowController?

    let popover = NSPopover()
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var eventMonitor: EventMonitor?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        print("AppDelegate")
        
        RealmMigrationManager.migrate()
        
        PlayerManager.sharedManager.statusItem = statusItem
        
        if let button = statusItem.button {
            button.imagePosition = .imageLeft
            button.image = NSImage(named: "Star")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        popover.contentViewController = StatusItemViewController.loadFromNib()
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: { (event) -> () in
            if self.popover.isShown {
                self.closePopover(event)
            }
        })
        
        // Load Window Controller
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        windowController = storyboard.instantiateController(withIdentifier: "MainWindowController") as? MainWindowController
        windowController?.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // ===============
    // MARK: - Helpers
    // ===============
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

}

