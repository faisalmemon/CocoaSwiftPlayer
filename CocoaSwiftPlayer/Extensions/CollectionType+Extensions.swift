//
//  CollectionType+Extensions.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 9/2/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Foundation

extension Collection {
    
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
    
}
