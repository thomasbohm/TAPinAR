//
//  BluetoothHandler.swift
//  TestApp
//
//  Created by Thomas Böhm on 12.06.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import UIKit
import CoreBluetooth

extension ARViewController: CBCentralManagerDelegate, CBPeripheralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            bluetoothPoweredOn = true
            
            centralManager?.scanForPeripherals(withServices: nil, options:  nil)
        case .poweredOff:
            bluetoothPoweredOn = false
            let alert = UIAlertController(title: "Bluetooth turned off.", message: "Please turn on bluetooth", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        default:
            print("state updated to \(central.state)")
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            bluetoothPoweredOn = true
            
            advertiseQueue.async {
                self.handleAdvertisement()
            }
        case .poweredOff:
            bluetoothPoweredOn = false
            print("Is Bluetooth turned on?")
        default:
            print("state updated to \(peripheral.state)")
        }
    }
    
    // called when discovered peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // filter out unimportant peripherals
        guard peripheral.name == nil && advertisementData.count == 2 else {
            return
        }
        let value = advertisementData["kCBAdvDataManufacturerData"].debugDescription
        guard !value.isEmpty && value.starts(with: "Optional(<8888") else {
            return
        }
        
        let unwrapped = unwrapAdvertisedData(for: value)
        //print(unwrapped)
        
        if !receivedStrings.contains(unwrapped) {
            receivedStrings.append(unwrapped)
            if var instance = Parser.decode(data: unwrapped) as? Instance {
                // check for temperature and pressure if there is already one existing
                if let instance = instance as? TriggerInstance, instance.type == .temperatureAndPressure {
                    let containsTempOrPress = instances.contains {
                        if let i = $0 as? TriggerInstance {
                            return i.type == .temperatureAndPressure && i.instId == instance.instId
                        } else {
                            return false
                        }
                    }
                    if containsTempOrPress {
                        return
                    }
                }
                
                addNodeForInstance(instance: &instance)
                instances.append(instance)
                print("new instance")
            } else {
                print("no instance: \(unwrapped)")
            }
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            fatalError(error.localizedDescription)
        }
    }
    
    // rotates through all uuids, advertising one uuid at a time for 0.1s
    private func handleAdvertisement() {
        print("handling advertisement started on \(Thread.current)")
        
        var index = 0
        while bluetoothPoweredOn {
            guard !advertisedStrings.isEmpty else {
                continue
            }
            
            peripheralManager.stopAdvertising()
            
            let string = advertisedStrings[index]
            let uuid = createFakeUUID(for: string)
            let advertisingData: [String: Any] = [
                CBAdvertisementDataServiceUUIDsKey: [uuid]
            ]
            
            peripheralManager.startAdvertising(advertisingData)
            
            index += 1
            if index >= advertisedStrings.count {
                index = 0
            }
            usleep(100000) // 0.1 seconds
        }
    }
    
    // unwraps the advertised value from e.g. "Optional(<8888 111>)" to "111"
    private func unwrapAdvertisedData(for string: String) -> String {
        var str = String(string.suffix(string.count - 14))
        str.removeLast()
        str.removeLast()
        let c = str.split(separator: " ")
        str = c.reduce("") {
            return $0 + $1
        }
        
        return String(str)
    }
    
    // creates a fake uuid filled up with 8888 and zeros in the front e.g. for "11111111" it returns CBUUID(00000000-0000-0000-0000-888811111111)
    private func createFakeUUID(for string: String) -> CBUUID {        
        let fillCount = 32 - string.count
        var filledString =  String(repeating: "0", count: fillCount - 4) + String(repeating: "8", count: 4) + string

        filledString.insert("-", at: filledString.index(filledString.startIndex, offsetBy: 20))
        filledString.insert("-", at: filledString.index(filledString.startIndex, offsetBy: 16))
        filledString.insert("-", at: filledString.index(filledString.startIndex, offsetBy: 12))
        filledString.insert("-", at: filledString.index(filledString.startIndex, offsetBy: 8))
        
        return CBUUID(string: filledString)
    }
}
