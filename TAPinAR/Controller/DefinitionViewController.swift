//
//  DefinitionViewController.swift
//  TestApp
//
//  Created by Thomas Böhm on 19.06.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import UIKit

class DefinitionViewController: UIViewController {

    var instance: Instance!
    var availabeDefinitions = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let instance = instance as? TriggerInstance {
            if instance.type == .button {
                availabeDefinitions.append("Pressed down")
                availabeDefinitions.append("Released")
            }
            if instance.type == .temperatureAndPressure {
                availabeDefinitions.append("Temperature ...")
                availabeDefinitions.append("Temperature < 30ºC")
                availabeDefinitions.append("Temperature > 30ºC")
                availabeDefinitions.append("Pressure ...")
            }
        } else if let instance = instance as? ActionInstance {
            if instance.type == .led {
                availabeDefinitions.append("LED on ...")
                availabeDefinitions.append("LED on red")
                availabeDefinitions.append("LED on blue")
                availabeDefinitions.append("LED off")
            }
           
            if instance.type == .player {
                availabeDefinitions.append("Play Tune 1")
                availabeDefinitions.append("Play Tune 2")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func createDefinition(text: String, arVC: ARViewController) {
        if let instance = instance as? TriggerInstance {
            switch instance.type {
            case .button:
                let definition = TriggerDefinition(type: .button, instId: instance.instId, description: text)
                let isDown = text == "Pressed down"
                arVC.definitions.append(definition)
                arVC.advertisedStrings.append(Parser.encodeTriggerButton(triggerId: definition.id,
                                                                         instId: definition.instId,
                                                                         isDown: isDown))
            case .temperatureAndPressure:
                if text == "Temperature ..." {
                    let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "RangePicker") as! RangePickerViewController
                    customAlert.descriptor = "Temperature"
                    customAlert.providesPresentationContextTransitionStyle = true
                    customAlert.definesPresentationContext = true
                    customAlert.modalPresentationStyle = .overCurrentContext
                    customAlert.modalTransitionStyle = .crossDissolve
                    customAlert.delegate = self
                    arVC.present(customAlert, animated: true, completion: nil)
                } else if text == "Pressure ..." {
                    let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "RangePicker") as! RangePickerViewController
                    customAlert.descriptor = "Pressure"
                    customAlert.providesPresentationContextTransitionStyle = true
                    customAlert.definesPresentationContext = true
                    customAlert.modalPresentationStyle = .overCurrentContext
                    customAlert.modalTransitionStyle = .crossDissolve
                    customAlert.delegate = self
                    arVC.present(customAlert, animated: true, completion: nil)
                } else if text == "Temperature < 30ºC" {
                    let definition = TriggerDefinition(type: .temperatureAndPressure, instId: instance.instId, description: text)
                    arVC.definitions.append(definition)
                    arVC.advertisedStrings.append(Parser.encodeTriggerRange(triggerId: definition.id,
                                                                           instId: definition.instId,
                                                                           operatorId: 2,
                                                                           operand: Float(30.0),
                                                                           sndOperand: nil,
                                                                           isTemperature: true))
                } else if text == "Temperature > 30ºC" {
                    let definition = TriggerDefinition(type: .temperatureAndPressure, instId: instance.instId, description: text)
                    arVC.definitions.append(definition)
                    arVC.advertisedStrings.append(Parser.encodeTriggerRange(triggerId: definition.id,
                                                                           instId: definition.instId,
                                                                           operatorId: 1,
                                                                           operand: Float(30.0),
                                                                           sndOperand: nil,
                                                                           isTemperature: true))
                }
            }
        } else if let instance = instance as? ActionInstance {
            switch instance.type {
            case .led:
                if text == "LED on ..." {
                    let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "ColorPicker") as! ColorPickerViewController
                    customAlert.providesPresentationContextTransitionStyle = true
                    customAlert.definesPresentationContext = true
                    customAlert.modalPresentationStyle = .overCurrentContext
                    customAlert.modalTransitionStyle = .crossDissolve
                    customAlert.delegate = self
                    arVC.present(customAlert, animated: true, completion: nil)
                    
                } else if text == "LED off" {
                    let definition = ActionDefinition(type: .led, instId: instance.instId, description: text)
                    arVC.definitions.append(definition)
                    arVC.advertisedStrings.append(Parser.encodeActionLED(actionId: definition.id,
                                                                         instId: definition.instId,
                                                                         redValue: 0,
                                                                         greenValue: 0,
                                                                         blueValue: 0))
                } else if text == "LED on red" {
                    let definition = ActionDefinition(type: .led, instId: instance.instId, description: "LED on", color: .red)
                    arVC.definitions.append(definition)
                    arVC.advertisedStrings.append(Parser.encodeActionLED(actionId: definition.id,
                                                                         instId: definition.instId,
                                                                         redValue: 255,
                                                                         greenValue: 0,
                                                                         blueValue: 0))
                } else if text == "LED on blue" {
                    let definition = ActionDefinition(type: .led, instId: instance.instId, description: "LED on", color: .blue)
                    arVC.definitions.append(definition)
                    arVC.advertisedStrings.append(Parser.encodeActionLED(actionId: definition.id,
                                                                         instId: definition.instId,
                                                                         redValue: 0,
                                                                         greenValue: 0,
                                                                         blueValue: 255))
                }
            case .player:
                let tuneId: UInt8 = text == "Play Tune 1" ? 1 : 2
                let definition = ActionDefinition(type: .player,
                                                  instId: instance.instId,
                                                  description: text,
                                                  tuneId: tuneId)
                arVC.definitions.append(definition)
                arVC.advertisedStrings.append(Parser.encodeActionTunePlayer(actionId: definition.id,
                                                                            instId: definition.instId,
                                                                            tuneId: tuneId))
            }
        }
    }
}

extension DefinitionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availabeDefinitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        let text = availabeDefinitions[indexPath.row]
        cell.textLabel?.text = text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let arVC = parent?.parent as? ARViewController, let text = tableView.cellForRow(at: indexPath)?.textLabel!.text {
            createDefinition(text: text, arVC: arVC)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension DefinitionViewController: RangePickerDelegate {
    func rangeSet(operatorId: UInt8, operatorString: String, firstOperand: Float, secondOperand: Float?, isTemperature: Bool) {
        if let arVC = parent?.parent as? ARViewController, let instance = instance as? TriggerInstance {
            var description = isTemperature ? "Temperature" : "Pressure"
            let unit = isTemperature ? "ºC" : "hPa"
            
            if operatorId == 5 {
                description += " between \(firstOperand) \(unit) and \(secondOperand!) \(unit)"
            } else {
                description += " \(operatorString) \(firstOperand) \(unit)"
            }
            
            let definition = TriggerDefinition(type: .temperatureAndPressure,
                                               instId: instance.instId,
                                               description: description)
            arVC.definitions.append(definition)
            arVC.advertisedStrings.append(Parser.encodeTriggerRange(triggerId: definition.id,
                                                                   instId: definition.instId,
                                                                   operatorId: operatorId,
                                                                   operand: firstOperand,
                                                                   sndOperand: secondOperand,
                                                                   isTemperature: isTemperature))
            navigationController?.popViewController(animated: true)
        }
    }
}

extension DefinitionViewController: ColorPickerDelegate {
    func colorSelected(color: UIColor) {
        if let arVC = parent?.parent as? ARViewController, let instance = instance as? ActionInstance {
            let (r,g,b,_) = color.rgb() ?? (255, 255, 255, 1)
            
            if r == 0 && g == 0 && b == 0 {
                let definition = ActionDefinition(type: .led, instId: instance.instId, description: "LED off")
                arVC.definitions.append(definition)
                arVC.advertisedStrings.append(Parser.encodeActionLED(actionId: definition.id,
                                                                     instId: definition.instId,
                                                                     redValue: 0,
                                                                     greenValue: 0,
                                                                     blueValue: 0))
            } else {
                let definition = ActionDefinition(type: .led, instId: instance.instId, description: "LED on", color: color)
                arVC.definitions.append(definition)
                arVC.advertisedStrings.append(Parser.encodeActionLED(actionId: definition.id,
                                                                     instId: definition.instId,
                                                                     redValue: r,
                                                                     greenValue: g,
                                                                     blueValue: b))
            }
            navigationController?.popViewController(animated: true)
        }
    }
}

extension UIColor {
    func rgb() -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = UInt8(fRed * 255.0)
            let iGreen = UInt8(fGreen * 255.0)
            let iBlue = UInt8(fBlue * 255.0)
            let iAlpha = UInt8(fAlpha * 255.0)
            
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            return nil
        }
    }
}
