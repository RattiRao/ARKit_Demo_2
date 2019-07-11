//
//  ViewController.swift
//  AR
//
//  Created by Prithvi on 09/07/19.
//  Copyright © 2019 Ratti. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SpriteKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
      
        //To show saved nodes in Scene View
        self.showSavedNodes()
        
        // Create a new scene
       // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)

        if let touchLocation = touches.first?.location(in: sceneView), let hit = sceneView.hitTest(touchLocation, types: .featurePoint).first
        {
            let anchor = ARAnchor(transform: hit.worldTransform)
            let node = sceneView.node(for: anchor)
            node?.removeFromParentNode()
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let anchorPlane = anchor as? ARPlaneAnchor
        {
            self.addRectanglePlane(anchor: anchorPlane, node : node)
        }
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension ViewController
{
    
    func showSavedNodes()
    {
        let arrSavedNode : Array<SCNNode> = Facade.shared.arrSavedNodes
        
        for node in arrSavedNode
        {
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    // Add rectange plane to surface
    func addRectanglePlane(anchor : ARPlaneAnchor, node : SCNNode)
    {
        let width : CGFloat = CGFloat(anchor.extent.x)
        let height : CGFloat = CGFloat(anchor.extent.z)
        
        let planeGeometry : SCNPlane = SCNPlane.init(width: width, height: height)
        
        let sceneDescription = SKScene.init(fileNamed: "PlaneDescription")
        
        if let lblNode = sceneDescription?.childNode(withName: "lblDescription") as? SKLabelNode
        {
            lblNode.text = String.init(format: AppHelper.Constants.message.areaRectange, (width * height))
        }
        
        planeGeometry.materials.first?.diffuse.contents = sceneDescription //UIColor.init(red: 135.0/255.0, green: 206.0/255.0, blue: 250.0/255.0, alpha: 0.5)
        
        let planeNode : SCNNode = SCNNode.init(geometry: planeGeometry)

        planeNode.position = SCNVector3.init(anchor.center.x, anchor.center.y, anchor.center.y)
        planeNode.eulerAngles.x = -.pi/2
        
        node.addChildNode(planeNode)
        
        //To add on Main Scene
        sceneView.scene.rootNode.addChildNode(node)
        
        //Save Nodes
        Facade.shared.save(node: node, childNode: planeNode)
    }
}

