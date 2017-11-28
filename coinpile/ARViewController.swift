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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene
        setUpLights()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        let numberOfCoins:Double = 100
        let coinsPerSecond:Double = 8
        let coinInterval:Double = 1.0 / coinsPerSecond
        let coinFlowDuration:Double = numberOfCoins/coinsPerSecond
        
        let coinFlowTimer = Timer.scheduledTimer(withTimeInterval: coinInterval, repeats: true) { _ in
            self.sceneView.scene.rootNode.addChildNode(self.newCoin())
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: coinFlowDuration, repeats: false) { _ in
            coinFlowTimer.invalidate()
        }
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
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
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
        coinNode.position = SCNVector3(x: 0.0, y: 1.5, z: 0.5)
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
