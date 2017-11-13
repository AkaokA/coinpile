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
import CoreMotion

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    let motionManager = CMMotionManager()
    let bgColor = UIColor(red: 0.97, green: 0.97, blue: 0.96, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0.2, z: 3)
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi/8, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.light?.intensity = 750
        lightNode.position = SCNVector3(x: -3.0, y: 10.0, z: -3.0)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let wallWidth:CGFloat = 10
        let wallHeight:CGFloat = 10
        let wallThickness:CGFloat = 1

        // configure walls
        let floorShape = SCNBox(width: wallWidth, height: wallThickness, length: wallHeight, chamferRadius: 0.0)
        floorShape.firstMaterial?.lightingModel = .constant
        floorShape.firstMaterial?.diffuse.contents = bgColor
        let floorNode = SCNNode(geometry: floorShape)
        floorNode.position = SCNVector3(x: 0.0, y: -2.0, z: 0.0)
        let floorPhysicsShape = SCNPhysicsShape(geometry: floorShape, options: nil)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: floorPhysicsShape)
        scene.rootNode.addChildNode(floorNode)
        
        let ceilingNode = SCNNode(geometry: floorShape)
        ceilingNode.position = SCNVector3(x: 0.0, y: 1.75, z: 0.0)
        ceilingNode.physicsBody = SCNPhysicsBody(type: .static, shape: floorPhysicsShape)
        scene.rootNode.addChildNode(ceilingNode)
        
        let wallShape = SCNBox(width: wallWidth, height: wallHeight, length: wallThickness, chamferRadius: 0)
        wallShape.firstMaterial?.lightingModel = .constant
        wallShape.firstMaterial?.diffuse.contents = bgColor
        let wallPhysicsShape = SCNPhysicsShape(geometry: wallShape, options: nil)
        
        let backWallNode = SCNNode(geometry: wallShape)
        backWallNode.position = SCNVector3(x: 0.0, y: 0.0, z: -0.75)
        backWallNode.physicsBody = SCNPhysicsBody(type: .static, shape: wallPhysicsShape)
        scene.rootNode.addChildNode(backWallNode)
        
        let frontWallNode = SCNNode(geometry: wallShape)
        frontWallNode.position = SCNVector3(x: 0.0, y: 0.0, z: 2.0)
        frontWallNode.physicsBody = SCNPhysicsBody(type: .static, shape: wallPhysicsShape)
        scene.rootNode.addChildNode(frontWallNode)
        
        let sideWallPositionOffset:Float = 1.75
        let sideWallAngle:Float = Float.pi * 0.42
        
        let leftWallNode = SCNNode(geometry: wallShape)
        leftWallNode.position = SCNVector3(x: -sideWallPositionOffset, y: 0.0, z: 0.0)
        leftWallNode.eulerAngles = SCNVector3(x: 0, y: -sideWallAngle, z: 0)
        leftWallNode.physicsBody = SCNPhysicsBody(type: .static, shape: wallPhysicsShape)
        scene.rootNode.addChildNode(leftWallNode)
        
        let rightWallNode = SCNNode(geometry: wallShape)
        rightWallNode.position = SCNVector3(x: sideWallPositionOffset, y: 0.0, z: 0.0)
        rightWallNode.eulerAngles = SCNVector3(x: 0, y: sideWallAngle, z: 0)
        rightWallNode.physicsBody = SCNPhysicsBody(type: .static, shape: wallPhysicsShape)
        scene.rootNode.addChildNode(rightWallNode)
        
        // configure physics simulation
        scene.physicsWorld.speed = 1.0
        
        // global forces
        let globalForceNode = SCNNode()
        globalForceNode.name = "globalForceNode"
        globalForceNode.physicsField = SCNPhysicsField.linearGravity()
        scene.rootNode.addChildNode(globalForceNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        scnView.delegate = self
        scnView.isPlaying = true
        
        // show statistics such as fps and timing information
        // scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = bgColor
        
        // start and stop dropping coins
        let numberOfCoins:Double = 100
        let coinsPerSecond:Double = 8
        let coinInterval:Double = 1.0 / coinsPerSecond
        let coinFlowDuration:Double = numberOfCoins/coinsPerSecond
        
        let coinFlowTimer = Timer.scheduledTimer(withTimeInterval: coinInterval, repeats: true) { _ in
            scene.rootNode.addChildNode(self.newCoin())
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: coinFlowDuration, repeats: false) { _ in
           coinFlowTimer.invalidate()
        }
        
        // start device motion
        motionManager.startDeviceMotionUpdates()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.motionUpdate()
    }
    
    func motionUpdate() {
        let scnView = self.view as! SCNView
        
        if let MotionData = self.motionManager.deviceMotion?.userAcceleration {
            let accelVector = SCNVector3(x: Float(MotionData.x), y: Float(MotionData.y), z: Float(MotionData.z))
            var accelStrength = sqrtf( powf(accelVector.x, 2) + powf(accelVector.y, 2) + powf(accelVector.z, 2) )
            
            let globalForceNode = scnView.scene?.rootNode.childNode(withName: "globalForceNode", recursively: false)
            globalForceNode?.physicsField?.direction = accelVector
            
            let maxStrength = Float(1.5)
            if accelStrength > maxStrength {
                accelStrength = maxStrength
            }
            globalForceNode?.physicsField?.strength = CGFloat(accelStrength * 50)
        }
    }
    
    func newCoin() -> SCNNode {
        let coin = SCNCylinder(radius: 0.2, height: 0.04)
        coin.radialSegmentCount = 32
        
        coin.firstMaterial?.lightingModel = .physicallyBased
        coin.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/coin_texture.png")
        coin.firstMaterial?.normal.contents = UIImage(named: "art.scnassets/coin_normal_map.png")
        coin.firstMaterial?.roughness.contents = NSNumber(value: 0.5)
        coin.firstMaterial?.metalness.contents = NSNumber(value: 1.0)
        
        let coinNode = SCNNode(geometry: coin)
        coinNode.position = SCNVector3(x: 0.0, y: 1.5, z: 0.5)
        coinNode.eulerAngles = SCNVector3(x: Float.pi * randomAroundZero(), y: Float.pi * randomAroundZero(), z: Float.pi * randomAroundZero())
        
        let coinPhysicsShape = SCNPhysicsShape(geometry: coin, options: nil)
        coinNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: coinPhysicsShape)
        coinNode.physicsBody?.friction = 0.4
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


