//
//  Parser.swift
//  TestApp
//
//  Created by Thomas Böhm on 03.07.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import Foundation

class Parser {
    
    static func encodeRule(ruleId: UInt8, triggerId: UInt8, actionId: UInt8) -> String {
        return "63" + String(format: "%02X", ruleId) + String(format: "%02X", triggerId) + String(format: "%02X", actionId)
    }
    
    static func encodeActionLED(actionId: UInt8, instId: UInt8, redValue: UInt8, greenValue: UInt8, blueValue: UInt8) -> String {
        var str = "46"
        str += String(format: "%02X", actionId)
        str += "01"
        str += String(format: "%02X", instId)
        str += String(format: "%02X", redValue)
        str += String(format: "%02X", greenValue)
        str += String(format: "%02X", blueValue)
        return str
    }
    
    static func encodeActionTunePlayer(actionId: UInt8, instId: UInt8, tuneId: UInt8) -> String {
        var str = "44"
        str += String(format: "%02X", actionId)
        str += "04"
        str += String(format: "%02X", instId)
        str += String(format: "%02X", tuneId)
        return str
    }
    
    static func encodeTriggerButton(triggerId: UInt8, instId: UInt8, isDown: Bool) -> String {
        var str = "24"
        str += String(format: "%02X", triggerId)
        str += "03"
        str += String(format: "%02X", instId)
        if isDown {
            str += "00"
        } else {
            str += "01"
        }
        return str
    }
    
    static func encodeTriggerRange(triggerId: UInt8, instId: UInt8, operatorId: UInt8, operand: Float, sndOperand: Float?, isTemperature: Bool) -> String {
        var str = ""
        if sndOperand == nil{
            str += "28"
        } else {
            str += "2C"
        }
        str += String(format: "%02X", triggerId)
        str += isTemperature ? "01" : "02"
        str += String(format: "%02X", instId)
        str += String(format: "%02X", operatorId)
        
        str += reversedHexString(for: operand)
        
        if let sndOperand = sndOperand {
            str += reversedHexString(for: sndOperand)
        }
        
        return str
    }
    
    static func decode(data: String) -> Any? {
        guard let bytes = data.stringToBytes() else {
            return nil
        }
        
        // Type: Descriptor, Length: 15 --> Location Descriptor
        if bytes[0] == 0xAF {
            return createInstance(bytes)
        }
        
        return nil
    }
    
    private static func reversedHexString(for float: Float) -> String {
        var description = (withUnsafeBytes(of: float) { Data($0) } as NSData).description
        description.removeFirst()
        description.removeLast()
        
        let f = Array(description)
        
        var inversed = ""
        inversed.insert(f[1], at: inversed.startIndex)
        inversed.insert(f[0], at: inversed.startIndex)
        inversed.insert(f[3], at: inversed.startIndex)
        inversed.insert(f[2], at: inversed.startIndex)
        inversed.insert(f[5], at: inversed.startIndex)
        inversed.insert(f[4], at: inversed.startIndex)
        inversed.insert(f[7], at: inversed.startIndex)
        inversed.insert(f[6], at: inversed.startIndex)
        
        return inversed
    }
    
    private static func createInstance(_ bytes: [UInt8]) -> Instance? {
        
        let descriptorType = bytes[1]
        let instId = bytes[3]
        
        let xBytes = Array<UInt8>(bytes[4..<8].reversed())
        var x: Float = 0.0
        memccpy(&x, xBytes, 4, 4)
        let yBytes = Array<UInt8>(bytes[8..<12].reversed())
        var y: Float = 0.0
        memccpy(&y, yBytes, 4, 4)
        let zBytes = Array<UInt8>(bytes[12..<16].reversed())
        var z: Float = 0.0
        memccpy(&z, zBytes, 4, 4)
        
        if descriptorType == 1 {
            let triggerType: TriggerType
            if bytes[2] == 1 {
                triggerType = .temperatureAndPressure
            } else if bytes[2] == 3 {
                triggerType = .button
            } else {
                return nil
            }
            
            return TriggerInstance(instId: instId, x: x, y: y, z: z, type: triggerType)
            
        } else if descriptorType == 2 {
            let actionType: ActionType
            if bytes[2] == 1 {
                actionType = .led
            } else if bytes[2] == 4 {
                actionType = .player
            } else {
                return nil
            }
            
            return ActionInstance(instId: instId, x: x, y: y, z: z, type: actionType)
        }
        
        return nil
    }
}

extension String {
    func stringToBytes() -> [UInt8]? {
        let length = self.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = self.startIndex
        for _ in 0..<length/2 {
            let nextIndex = self.index(index, offsetBy: 2)
            if let b = UInt8(self[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
}
