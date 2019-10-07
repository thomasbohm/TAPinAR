//
//  TriggerDefinition.swift
//  TestApp
//
//  Created by Thomas Böhm on 25.06.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import Foundation

class TriggerDefinition: Definition {
 
    private static var idCounter: UInt8 = 1
    
    let id: UInt8
    let instId: UInt8
    let triggerType: TriggerType?
    let actionType: ActionType?
    let description: String
    
    var isConnected: Bool
    
    init(type: TriggerType, instId: UInt8, description: String) {
        self.id = TriggerDefinition.idCounter
        TriggerDefinition.idCounter += 1
        
        self.triggerType = type
        self.actionType = nil
        self.instId = instId
        self.description = description
        self.isConnected = false
    }
}
