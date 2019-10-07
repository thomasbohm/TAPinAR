//
//  ActionInstance.swift
//  TestApp
//
//  Created by Thomas Böhm on 04.07.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import Foundation
import SceneKit

class ActionInstance: Instance {
    
    let type: ActionType
    
    let instId: UInt8
    let x: Float
    let y: Float
    let z: Float
    var label: String? = nil
    var node: SCNNode? = nil

    init(instId: UInt8, x: Float, y: Float, z: Float, type: ActionType) {
        self.instId = instId
        self.x = x
        self.y = y
        self.z = z
        self.type = type
    }
}

enum ActionType {
    case led, player
}
