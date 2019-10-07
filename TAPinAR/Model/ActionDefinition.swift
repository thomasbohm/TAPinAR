//
//  ActionDefinition.swift
//  TestApp
//
//  Created by Thomas Böhm on 25.06.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import Foundation
import UIKit

class ActionDefinition: Definition {
    
    private static var idCounter: UInt8 = 1

    let id: UInt8
    let instId: UInt8
    let triggerType: TriggerType?
    let actionType: ActionType?
    let description: String
    
    var isConnected: Bool
    var color: UIColor?
    var tuneId: UInt8?
    
    init(type: ActionType, instId: UInt8, description: String, color: UIColor? = nil, tuneId: UInt8? = nil) {
        self.id = ActionDefinition.idCounter
        ActionDefinition.idCounter += 1
        
        self.triggerType = nil
        self.actionType = type
        self.instId = instId
        self.description = description
        self.isConnected = false
        self.color = color
        self.tuneId = tuneId
    }
}
