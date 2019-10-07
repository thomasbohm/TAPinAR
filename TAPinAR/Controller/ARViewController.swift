//
//  ARViewController
//  TestApp
//
//  Created by Thomas Böhm on 26.05.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreBluetooth

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    var instances = [Instance]()
    var definitions = [Definition]()
    var rules = [Rule]()
    
    var worldOriginIsSet = false
    var userAdvices: NSAttributedString? = NSMutableAttributedString() {
        didSet {
            infoLabel.attributedText = self.userAdvices
        }
    }
    
    // Bluetooth Handling Properties
    var advertiseQueue: DispatchQueue!
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var bluetoothPoweredOn = false
    var advertisedStrings = [String]()
    var receivedStrings = [String]()
    // ---
    
    var instanceViewController: InstanceViewController!
    var instanceForNode = [SCNNode: Instance]()
    var startNode: SCNNode?
    
    var highlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.25, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.25, duration: 0.25),
            .fadeOpacity(to: 1.0, duration: 0.25)
            ])
    }
    
    var blinkingAction: SCNAction {
        return .repeatForever(.sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.25, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            ]))
    }
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBAction func resetPressed(_ sender: UIButton) {
        resetTracking()
    }
    
    @objc func handleTap(rec: UITapGestureRecognizer) {
        if rec.state == .ended {
            let location = rec.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(location, options: nil)
            if let node = hitTestResults.first?.node {
                
                guard node.name == "sphereNode" || node.name == "boxNode" else { return }
                guard let instance = instanceForNode[node] else { return }
                UISelectionFeedbackGenerator().selectionChanged()
                
                if startNode == nil {
                    showInstanceView(node, instance, isConnecting: false)
                } else {
                    showInstanceView(node, instance, isConnecting: true)
                }
            } else {
                print(advertisedStrings)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.debugOptions = [.showWorldOrigin]
        
        // Instance Container
        instanceViewController = ((children.first as! UINavigationController).children.first as! InstanceViewController)
        instanceViewController.delegate = self
        containerView.alpha = 0;
        // ---
        
        // Bluetooth Handler
        advertiseQueue = DispatchQueue(label: "advertise-queue", qos: .background)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        // ---
        

//        let instance = ActionInstance(instId: 1, x: 0.1, y: 0, z: 0.1, type: .led)
//        addNodeForInstance(instance: instance)
//        instances.append(instance)
//        let instance2 = ActionInstance(instId: 1, x: 0, y: 0, z: 0.1, type: .tunePlayer)
//        addNodeForInstance(instance: instance2)
//        instances.append(instance2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "ReferenceImages", bundle: nil) else {
            fatalError("Couldn't load tracking images.")
        }
        configuration.detectionImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARImageAnchor {
            let msg = "Look around for Triggers and Actions. Tap on the boxes to interact."
            let str = NSMutableAttributedString(string: msg)
            str.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.09319030493, green: 0.7379360795, blue: 0.609675765, alpha: 1) , range: NSRange(location:16,length:8))
            str.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.6091628671, green: 0.3471981585, blue: 0.7143893838, alpha: 1), range: NSRange(location:29,length:7))
            
            // Haptical feedback
            DispatchQueue.main.async {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self.userAdvices = str
            }
            
            sceneView.session.setWorldOrigin(relativeTransform: anchor.transform)
            
            worldOriginIsSet = true
            instances.forEach {
                $0.node?.opacity = 1.0
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARImageAnchor {
            sceneView.session.setWorldOrigin(relativeTransform: anchor.transform)
        }
    }
    
    // MARK: - Private Methods
    
    // show container for tapped instance
    private func showInstanceView(_ node: SCNNode, _ instance: Instance, isConnecting: Bool) {
        if !isConnecting, !node.hasActions {
            node.runAction(highlightAction)
        } else if !node.hasActions {
            node.runAction(blinkingAction)
        }
        
        instanceViewController.instance = instance
        instanceViewController.viewWillAppear(true)
        
        (children.first as! UINavigationController).popToRootViewController(animated: false)
        
        containerView.alpha = 0.0
        containerView.frame.origin.y = containerView.frame.origin.y + containerView.frame.height
        UIView.animate(withDuration: 0.4, animations: {
            self.containerView.alpha = 1.0
            self.containerView.frame.origin.y = self.containerView.frame.origin.y - self.containerView.frame.height
        })
    }
    
    func addNodeForInstance(instance: inout Instance) {
        let position = SCNVector3(x: instance.x, y: instance.y, z: instance.z)
        let color: UIColor = instance is TriggerInstance ? #colorLiteral(red: 0.09319030493, green: 0.7379360795, blue: 0.609675765, alpha: 1) : #colorLiteral(red: 0.6091628671, green: 0.3471981585, blue: 0.7143893838, alpha: 1)
        let node = createBoxNode(for: instance, at: position, color: color)
        instance.node = node
        instanceForNode[node] = instance
        
        if !worldOriginIsSet {
            node.opacity = 0.0
        }
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    private func createSphereNode(position: SCNVector3, radius: CGFloat = 0.02, color: UIColor = .red) -> SCNNode {
        let sphere = SCNSphere(radius: radius)
        let materialSphere = SCNMaterial()
        materialSphere.diffuse.contents = color
        sphere.materials = [materialSphere]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = position
        sphereNode.name = "sphereNode"
        
        return sphereNode
    }
    
    private func createBoxNode(for instance: Instance, at position: SCNVector3, color: UIColor) -> SCNNode {
        let box = SCNBox(width: 0.04, height: 0.04, length: 0.04, chamferRadius: 0.005)
        let image = nodeImage(for: instance)
        let imageMaterial = SCNMaterial()
        imageMaterial.diffuse.contents = image
        let colorMaterial = SCNMaterial()
        colorMaterial.diffuse.contents = color
        
        // blank sides, icon on the top
        box.materials = [colorMaterial, colorMaterial, colorMaterial, colorMaterial, imageMaterial, colorMaterial]
        let node = SCNNode(geometry: box)
        node.position = position
        node.name = "boxNode"
        
        return node
    }
    
    private func nodeImage(for instance: Instance) -> UIImage {
        var name = ""
        if let instance = instance as? TriggerInstance {
            switch instance.type {
            case .button:
                name = "button.png"
            case .temperatureAndPressure:
                name = "temperature.png"
            }
        } else if let instance = instance as? ActionInstance {
            switch instance.type {
            case .led:
                name = "led.png"
            case .player:
                name = "player.png"
            }
        }
        guard !name.isEmpty, let image = UIImage(named: name) else {
            fatalError("\(#function): could not load image for file \(name)")
        }
        
        return image
    }

}

extension ARViewController: RuleCreationDelegate {
    
    // called when trigger definition in list was selected
    func didSelectRuleStart(for node: SCNNode) {
        // hides all other trigger instances and rules to give a better overview for available action instances
        instances.forEach {
            if let instance = $0 as? TriggerInstance {
                instance.node?.opacity = 0.0
            }
        }
        rules.forEach {
            $0.node.opacity = 0.0
        }
        
        startNode = node
        startNode?.opacity = 1.0
        startNode?.runAction(blinkingAction)
    }
    
    // called when action definition was selected
    func didSelectRuleEnd(for endNode: SCNNode) -> SCNNode? {
        guard let startNode = startNode else {
            return nil
        }
        
        instances.forEach {
            $0.node?.opacity = 1.0
            $0.node?.removeAllActions()
        }
        rules.forEach {
            $0.node.opacity = 1.0
        }
        
        let node = SCNNode().arrowNode(from: startNode.position, to: endNode.position)
        sceneView.scene.rootNode.addChildNode(node)

        self.startNode = nil
        return node
    }
    
}

