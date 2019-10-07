//
//  RangePickerViewController.swift
//  TestApp
//
//  Created by Thomas Böhm on 06.07.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import UIKit

protocol RangePickerDelegate {
    func rangeSet(operatorId: UInt8, operatorString: String, firstOperand: Float, secondOperand: Float?, isTemperature: Bool)
}

class RangePickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let operators = [">", "in", "<"]
    
    var descriptor = ""    
    var delegate: RangePickerDelegate?
    
    @IBOutlet weak var descriptorLabel: UILabel!
    
    @IBOutlet weak var firstOperand: UITextField!
    @IBOutlet weak var secondOperand: UITextField!
    @IBOutlet weak var operatorPicker: UIPickerView!

    @IBAction func donePressed(_ sender: UIButton) {
        guard let text = descriptorLabel.text else {
            return
        }
        
        let operatorId: UInt8
        let index = operatorPicker.selectedRow(inComponent: 0)
        switch index {
        case 0:
            operatorId = 1
        case 1:
            operatorId = 5
        case 2:
            operatorId = 2
        default:
            return
        }
        
        if operatorId != 5 {
            guard !firstOperand.text!.isEmpty else {
                firstOperand.layer.borderColor = UIColor.red.cgColor
                firstOperand.layer.borderWidth = 1.0
                return
            }
            let str = firstOperand.text as NSString?
            if let f = str {
                delegate?.rangeSet(operatorId: operatorId,
                                   operatorString: operators[index],
                                   firstOperand: f.floatValue,
                                   secondOperand: nil,
                                   isTemperature: text == "Temperature")
            }
            
            self.dismiss(animated: true, completion: nil)
        } else {
            guard !firstOperand.text!.isEmpty && !secondOperand.text!.isEmpty else {
                firstOperand.layer.borderColor = UIColor.red.cgColor
                firstOperand.layer.borderWidth = 1.0
                secondOperand.layer.borderColor = UIColor.red.cgColor
                secondOperand.layer.borderWidth = 1.0
                return
            }
            
            let str = firstOperand.text as NSString?
            let str2 = secondOperand.text as NSString?

            if let f = str, let f2 = str2 {
                delegate?.rangeSet(operatorId: operatorId,
                                   operatorString: operators[index],
                                   firstOperand: f.floatValue,
                                   secondOperand: f2.floatValue,
                                   isTemperature: text == "Temperature")
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptorLabel.text = descriptor
        operatorPicker.dataSource = self
        operatorPicker.delegate = self
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return operators.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return operators[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 1 {
            secondOperand.isHidden = false
            firstOperand.placeholder = "From"
            secondOperand.placeholder = "To"
        } else {
            firstOperand.placeholder = "Operand"
            secondOperand.text = ""
            secondOperand.isHidden = true
        }
    }
    
}
