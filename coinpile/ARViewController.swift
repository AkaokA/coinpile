//
//  ARViewController.swift
//  coinpile
//
//  Created by Eric Akaoka on 2017-10-25.
//  Copyright © 2017 Eric Akaoka. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var anchors = [ARAnchor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*Implement this to provide a custom node for the given anchor.
     @discussion This node will automatically be added to the scene graph.
     If this method is not implemented, a node will be automatically created.
     If nil is returned the anchor will be ignored.
     @param renderer The renderer that will render the scene.
     @param anchor The added anchor.
     @return Node that will be mapped to the anchor or nil.
     */
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        var node:  SCNNode?
        if let planeAnchor = anchor as? ARPlaneAnchor {
            node = SCNNode()
            // let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            // let planeGeometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: planeHeight, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0.0)
//            let planeHeight:CGFloat = 0.01
            
            let planeGeometry = SCNFloor()
            planeGeometry.firstMaterial?.diffuse.contents = UIColor.clear
            let planePhysicsShape = SCNPhysicsShape(geometry: planeGeometry, options: nil)
            
            let planeNode = SCNNode(geometry: planeGeometry)
            planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: planePhysicsShape)
            planeNode.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
            
            //since SCNPlane is vertical, needs to be rotated -90 degrees on X axis to make a plane
//            planeNode.transform = SCNMatrix4MakeRotation(Float(-CGFloat.pi/2), 1, 0, 0)
            
            node?.addChildNode(planeNode)
            node?.addChildNode(self.newCoin())
            
            anchors.append(planeAnchor)
            
        } else {
            // haven't encountered this scenario yet
            print("not plane anchor \(anchor)")
        }
        return node
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
    
    func setUpLights() {
        let sceneView = self.view as! SCNView
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
        sceneView.scene?.rootNode.addChildNode(ambientLightNode)
        
        // create and add a directional light to the scene
        let lightNode = SCNNode()
        lightNode.position = SCNVector3(x: -0.5, y: 2, z: 0.75)
        
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.light?.intensity = 120
        lightNode.light?.spotInnerAngle = 45.0
        lightNode.light?.spotOuterAngle = 90.0
        lightNode.light?.castsShadow = true
        lightNode.light?.shadowSampleCount = 8
        lightNode.light?.shadowRadius = 2.0
        lightNode.light?.shadowBias = 1.5
        sceneView.scene?.rootNode.addChildNode(lightNode)
    }
    
    func dropCoins(parentNode:SCNNode) {
        let numberOfCoins:Double = 100
        let coinsPerSecond:Double = 8
        let coinInterval:Double = 1.0 / coinsPerSecond
        let coinFlowDuration:Double = numberOfCoins/coinsPerSecond
        
        let coinFlowTimer = Timer.scheduledTimer(withTimeInterval: coinInterval, repeats: true) { _ in
            parentNode.addChildNode(self.newCoin())
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: coinFlowDuration, repeats: false) { _ in
            coinFlowTimer.invalidate()
        }
    }
    
    func newCoin() -> SCNNode {
        let coin = SCNCylinder(radius: 0.2, height: 0.04)
        coin.radialSegmentCount = 24
        
        coin.firstMaterial?.lightingModel = .physicallyBased
        coin.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/coin_texture.png")
        coin.firstMaterial?.normal.contents = UIImage(named: "art.scnassets/coin_normal_map.png")
        coin.firstMaterial?.ambientOcclusion.contents = UIImage(named: "art.scnassets/coin_ao_map.png")
        coin.firstMaterial?.roughness.contents = NSNumber(value: 0.5)
        coin.firstMaterial?.metalness.contents = NSNumber(value: 1.0)
        
        let coinNode = SCNNode(geometry: coin)
        coinNode.position = SCNVector3(x: 0.0, y: 1.5, z: 0.0)
        coinNode.eulerAngles = SCNVector3(x: .pi * randomAroundZero(), y: .pi * randomAroundZero(), z: .pi * randomAroundZero())
        
        let coinPhysicsShape = SCNPhysicsShape(geometry: coin, options: nil)
        coinNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: coinPhysicsShape)
        coinNode.physicsBody?.friction = 0.25
        coinNode.physicsBody?.rollingFriction = 0.25
        
        let coinTorque = SCNVector4(x: randomAroundZero(), y: randomAroundZero(), z: randomAroundZero(), w: 0.25)
        coinNode.physicsBody?.applyTorque(coinTorque, asImpulse: true)
        
        return coinNode
    }
    
    func randomAroundZero() -> Float {
        // generate a random number between -1.0 and 1.0
        let randomPerc = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomValue = (randomPerc * 2) - 1
        return Float(randomValue)
    }
}
