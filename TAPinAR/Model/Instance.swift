//
//  Instance.swift
//  TestApp
//
//  Created by Thomas Böhm on 04.07.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import Foundation
import SceneKit

protocol Instance {
    
    var instId: UInt8 { get }
    var x: Float { get }
    var y: Float { get }
    var z: Float { get }
    var label: String? { get set }
    var node: SCNNode? { get set }
    
}
