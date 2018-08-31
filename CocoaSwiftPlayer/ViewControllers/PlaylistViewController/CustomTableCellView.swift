//
//  CustomTableCellView.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 15/2/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Cocoa

class CustomTableCellView: NSTableCellView {

    @IBOutlet weak var songCount: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
