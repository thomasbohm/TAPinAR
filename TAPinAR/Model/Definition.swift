//
//  Definition.swift
//  TestApp
//
//  Created by Thomas Böhm on 04.07.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import Foundation

protocol Definition: CustomStringConvertible {
    
    var id: UInt8 { get }
    var triggerType: TriggerType? { get }
    var actionType: ActionType? { get }
    var instId: UInt8 { get }
    var isConnected: Bool { get set }

}
