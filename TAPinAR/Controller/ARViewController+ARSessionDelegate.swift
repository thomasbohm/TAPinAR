//
//  ARViewController+ARSessionDelegate.swift
//  TestApp
//
//  Created by Thomas Böhm on 23.06.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import Foundation
import ARKit

extension ARViewController: ARSessionDelegate {
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: camera.trackingState)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        infoLabel.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking()
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        infoLabel.text = "Session was interrupted"
        infoLabel.superview?.superview?.isHidden = false
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        infoLabel.superview?.superview?.isHidden = true
        resetTracking()
    }
    
    func resetTracking() {
        worldOriginIsSet = false
        startNode = nil
        instances.forEach {
            $0.node?.removeAllActions()
        }
        
        let configuration = ARWorldTrackingConfiguration()
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "ReferenceImages", bundle: nil) else {
            fatalError("Couldn't load tracking images.")
        }
        configuration.detectionImages = trackingImages
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // Updates the UI to provide feedback for the state of the AR experience
    func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        let message: String
        
        switch trackingState {
        case .normal where !worldOriginIsSet:
            message = "Scan the TUM Logo to proceed."
            let str = NSMutableAttributedString(string: message)
            str.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.2509803922, green: 0.4392156863, blue: 0.6823529412, alpha: 1), range: NSRange(location: 9,length: 8))
            userAdvices = str
            return
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        case .limited(.relocalizing):
            message = "Relocating AR session."
            
        default:
            infoLabel.attributedText = userAdvices
            infoLabel.superview?.superview?.isHidden = userAdvices == nil
            return
        }
        
        infoLabel.text = message
        infoLabel.superview?.superview?.isHidden = message.isEmpty
    }
}
