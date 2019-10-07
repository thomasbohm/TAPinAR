//
//  DrawIcons.swift
//  TestApp
//
//  Created by Thomas Böhm on 14.06.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import Foundation
import UIKit

class DrawIcon {
    
    static var plus: UIView {
        return drawPlus()
    }
    
    static var circle: UIView {
        return drawCircle()
    }
    
    static var filledCircle: UIView {
        return drawFilledCircle()
    }
    
    private static func drawPlus() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 10,y: 10),
                                      radius: CGFloat(10),
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 0, green: 0.4392156863, blue: 0.9607843137, alpha: 1)
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 4, y: 10))
        linePath.addLine(to: CGPoint(x: 16, y: 10))
        linePath.close()
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = #colorLiteral(red: 0, green: 0.4392156863, blue: 0.9607843137, alpha: 1)
        lineLayer.lineWidth = 1.0
        
        view.layer.addSublayer(lineLayer)
        
        let linePath2 = UIBezierPath()
        linePath2.move(to: CGPoint(x: 10, y: 4))
        linePath2.addLine(to: CGPoint(x: 10, y: 16))
        linePath2.close()
        
        let lineLayer2 = CAShapeLayer()
        lineLayer2.path = linePath2.cgPath
        lineLayer2.strokeColor = #colorLiteral(red: 0, green: 0.4392156863, blue: 0.9607843137, alpha: 1)
        lineLayer2.lineWidth = 1.0
        
        view.layer.addSublayer(lineLayer2)
        
        return view
    }
    
    private static func drawCircle() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 10,y: 10),
                                      radius: CGFloat(10),
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 0, green: 0.4392156863, blue: 0.9607843137, alpha: 1)
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
        return view
        
    }
    
    private static func drawFilledCircle() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 10,y: 10),
                                      radius: CGFloat(6),
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0.4392156863, blue: 0.9607843137, alpha: 1)
        shapeLayer.strokeColor = #colorLiteral(red: 0, green: 0.4392156863, blue: 0.9607843137, alpha: 1)
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
        
        let circlePath2 = UIBezierPath(arcCenter: CGPoint(x: 10,y: 10),
                                       radius: CGFloat(10),
                                       startAngle: CGFloat(0),
                                       endAngle:CGFloat(Double.pi * 2),
                                       clockwise: true)
        
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.path = circlePath2.cgPath
        
        shapeLayer2.fillColor = UIColor.clear.cgColor
        shapeLayer2.strokeColor = #colorLiteral(red: 0, green: 0.4392156863, blue: 0.9607843137, alpha: 1)
        shapeLayer2.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer2)
        
        return view
    }
}
