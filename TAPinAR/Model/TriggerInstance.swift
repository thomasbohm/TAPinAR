//
//  TriggerInstance.swift
//  TestApp
//
//  Created by Thomas Böhm on 04.07.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import Foundation
import SceneKit

class TriggerInstance: Instance {
    
    let type: TriggerType

    let instId: UInt8
    let x: Float
    let y: Float
    let z: Float
    var label: String? = nil
    var node: SCNNode? = nil
    
    init(instId: UInt8, x: Float, y: Float, z: Float, type: TriggerType) {
        self.instId = instId
        self.x = x
        self.y = y
        self.z = z
        self.type = type
    }

}

enum TriggerType {
    case button, temperatureAndPressure
}
