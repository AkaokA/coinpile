//
//  GameViewController.swift
//  coinpile
//
//  Created by Eric Akaoka on 2017-10-25.
//  Copyright © 2017 Eric Akaoka. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 16)
        cameraNode.eulerAngles = SCNVector3Make(-Float.pi/8, 0, 0);
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.light?.intensity = 500.0
        lightNode.position = SCNVector3(x: -3.0, y: 10.0, z: -3.0)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        // configure physics simulation
        scene.physicsWorld.speed = 1.0
        
        // configure floor node
        let floor = SCNBox(width: 50, height: 5, length: 50, chamferRadius: 0.0)
        floor.firstMaterial?.lightingModel = .constant
        floor.firstMaterial?.diffuse.contents = UIColor(red: 0.97, green: 0.97, blue: 0.96, alpha: 1.0)
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 0.0, y: -4.0, z: 0.0)
        let floorPhysicsShape = SCNPhysicsShape(geometry: floor, options: nil)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: floorPhysicsShape)
        
        scene.rootNode.addChildNode(floorNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
//        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
//        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.96, alpha: 1.0)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // spawn a coin
        scnView.scene?.rootNode.addChildNode(newCoin())
    }
    
    func newCoin() -> SCNNode {
        let coin = SCNCylinder(radius: 0.8, height: 0.16)
        coin.firstMaterial?.lightingModel = .physicallyBased
        coin.firstMaterial?.diffuse.contents = UIColor(red: 0.67, green: 0.60, blue: 0.37, alpha: 1.0)
        coin.firstMaterial?.roughness.contents = NSNumber(value: 0.5)
        coin.firstMaterial?.metalness.contents = NSNumber(value: 1.0)
        
        let coinFaceImage = UIImage(named: "art.scnassets/coin_normal_map.png")
        coin.firstMaterial?.normal.contents = coinFaceImage
        
        let coinNode = SCNNode(geometry: coin)
        coinNode.position = SCNVector3(x: 0.0, y: 15.0, z: 0.0)
        
        let coinPhysicsShape = SCNPhysicsShape(geometry: coin, options: nil)
        coinNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: coinPhysicsShape)
        coinNode.physicsBody?.mass = 0.2
        coinNode.physicsBody?.friction = 0.8
        coinNode.physicsBody?.rollingFriction = 0.1
        coinNode.physicsBody?.damping = 0.1
        coinNode.physicsBody?.angularDamping = 0.4
        
        let randomPerc = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let coinTorque = SCNVector4(x: Float(randomPerc - 0.5), y: Float(randomPerc - 0.5), z: Float(randomPerc - 0.5), w: 0.75)
        coinNode.physicsBody?.applyTorque(coinTorque, asImpulse: true)
        coinNode.physicsBody?.applyForce(SCNVector3(Float(randomPerc/2 - 0.25), -2, Float(randomPerc/2 - 0.25)), asImpulse: true)
        
        return coinNode
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
