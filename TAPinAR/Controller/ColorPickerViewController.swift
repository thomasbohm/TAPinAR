//
//  ColorPickerViewController.swift
//  TestApp
//
//  Created by Thomas Böhm on 27.06.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate {
    func colorSelected(color: UIColor)
}

class ColorPickerViewController: UIViewController {

    let colorArray = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00,
                       0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]

    var delegate: ColorPickerDelegate?
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorImageView: UIImageView!
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        colorView.backgroundColor = uiColorFromHex(rgbValue: colorArray[Int(sender.value)])
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        delegate?.colorSelected(color: colorView.backgroundColor!)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        colorImageView.layer.borderWidth = 1.0
        colorImageView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        colorView.layer.borderWidth = 1.0
        colorView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        colorView.backgroundColor = uiColorFromHex(rgbValue: 0x05c000)
    }
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

}
