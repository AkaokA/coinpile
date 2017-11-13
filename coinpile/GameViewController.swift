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
    var accelVector = SCNVector3()
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
        
        // configure floor/ceiling node
        let floor = SCNBox(width: 100, height: 1, length: 100, chamferRadius: 0.0)
        floor.firstMaterial?.lightingModel = .constant
        floor.firstMaterial?.diffuse.contents = bgColor
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 0.0, y: -2.0, z: 0.0)
        let floorPhysicsShape = SCNPhysicsShape(geometry: floor, options: nil)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: floorPhysicsShape)
        scene.rootNode.addChildNode(floorNode)
        
        let ceilingNode = SCNNode(geometry: floor)
        ceilingNode.position = SCNVector3(x: 0.0, y: 1.75, z: 0.0)
        ceilingNode.physicsBody = SCNPhysicsBody(type: .static, shape: floorPhysicsShape)
        scene.rootNode.addChildNode(ceilingNode)
        
        // walls
        let wallWidth = CGFloat(100)
        let wallHeight = CGFloat(100)
        let wall = SCNBox(width: wallWidth, height: wallHeight, length: 1, chamferRadius: 0)
        wall.firstMaterial?.lightingModel = .constant
        wall.firstMaterial?.diffuse.contents = bgColor
        let wallPhysicsShape = SCNPhysicsShape(geometry: wall, options: nil)
        
        let backWallNode = SCNNode(geometry: wall)
        backWallNode.position = SCNVector3(x: 0.0, y: 0.0, z: -1)
        backWallNode.physicsBody = SCNPhysicsBody(type: .static, shape: wallPhysicsShape)
        scene.rootNode.addChildNode(backWallNode)
        
        let frontWallNode = SCNNode(geometry: wall)
        frontWallNode.position = SCNVector3(x: 0.0, y: 0.0, z: 2.0)
        frontWallNode.physicsBody = SCNPhysicsBody(type: .static, shape: wallPhysicsShape)
        scene.rootNode.addChildNode(frontWallNode)
        
        let leftWallNode = SCNNode(geometry: wall)
        leftWallNode.position = SCNVector3(x: -1.75, y: 0.0, z: 0.0)
        leftWallNode.eulerAngles = SCNVector3(x: 0, y: -Float.pi * 0.42, z: 0)
        leftWallNode.physicsBody = SCNPhysicsBody(type: .static, shape: wallPhysicsShape)
        scene.rootNode.addChildNode(leftWallNode)
        
        let rightWallNode = SCNNode(geometry: wall)
        rightWallNode.position = SCNVector3(x: 1.75, y: 0.0, z: 0.0)
        rightWallNode.eulerAngles = SCNVector3(x: 0, y: Float.pi * 0.42, z: 0)
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
//        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = bgColor
        
        // start dropping coins
        let timer = Timer.scheduledTimer(withTimeInterval: 1/7, repeats: true) { _ in
            scene.rootNode.addChildNode(self.newCoin())
        }
        
        // stop dropping coins after a while
        _ = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
           timer.invalidate()
        }
        
        // poll accelerometer
        motionManager.startDeviceMotionUpdates()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.motionUpdate()
    }
    
    func motionUpdate() {
        let scnView = self.view as! SCNView
        
        if let MotionData = self.motionManager.deviceMotion?.userAcceleration {
            accelVector = SCNVector3(x: Float(MotionData.x), y: Float(MotionData.y), z: Float(MotionData.z))
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
        coinNode.physicsBody?.friction = 0.5
        coinNode.physicsBody?.rollingFriction = 0.25
        
        let coinTorque = SCNVector4(x: randomAroundZero(), y: randomAroundZero(), z: randomAroundZero(), w: 0.25)
        coinNode.physicsBody?.applyTorque(coinTorque, asImpulse: true)
        
        return coinNode
    }
    
    func randomAroundZero() -> Float {
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


