//
//  MutableCollectionType+Extensions.swift
//  CocoaSwiftPlayer
//
//  Created by Harry Ng on 9/2/2016.
//  Copyright © 2016 STAY REAL. All rights reserved.
//

import Foundation

extension MutableCollection where Index == Int {
    
    mutating func shuffleInPlace() {
        
        // Algorithm is from https://stackoverflow.com/a/37843901/2715565
        
        for i in indices.dropLast() {
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: numericCast(arc4random_uniform(numericCast(diff))))
            swapAt(i, j)
        }
    }
    
}
