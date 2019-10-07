//
//  Rule.swift
//  TestApp
//
//  Created by Thomas Böhm on 25.06.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import Foundation
import SceneKit

class Rule {
    
    private static var idCounter: UInt8 = 1
    
    let id: UInt8
    let triggerId: UInt8
    let actionId: UInt8
    let node: SCNNode
    
    init(triggerId: UInt8, actionId: UInt8, node: SCNNode) {
        self.id = Rule.idCounter
        Rule.idCounter += 1
        
        self.triggerId = triggerId
        self.actionId = actionId
        self.node = node
    }
}
