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

class GameViewController: UIViewController {
    
    var coinsAreFlowing = false
    var timer = Timer()
    var globalTimer = Timer()
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
        ceilingNode.position = SCNVector3(x: 0.0, y: 2.5, z: 0.0)
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
        backWallNode.position = SCNVector3(x: 0.0, y: 0.0, z: -1.25)
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
        
        // allows the user to manipulate the camera
//        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
//        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = bgColor
        
        
        
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.150, repeats: true) { _ in
            scene.rootNode.addChildNode(self.newCoin())
        }
        coinsAreFlowing = true
        
        globalTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
            self.timer.invalidate()
        }
        
        

        motionManager.startDeviceMotionUpdates()
        _ = Timer.scheduledTimer(withTimeInterval: 0.01667, repeats: true) { _ in
            self.motionUpdate()
        }

    }
    
    var accelVector = SCNVector3()
    @objc func motionUpdate() {
        
        if let MotionData = self.motionManager.deviceMotion?.userAcceleration {
            accelVector = SCNVector3(x: Float(MotionData.x), y: Float(MotionData.y), z: Float(MotionData.z))
            let accelStrength = sqrtf( powf(accelVector.x, 2) + powf(accelVector.y, 2) + powf(accelVector.z, 2) )
            
            let scnView = self.view as! SCNView
            
            let globalForceNode = scnView.scene?.rootNode.childNode(withName: "globalForceNode", recursively: false)
            globalForceNode?.physicsField?.direction = accelVector
            globalForceNode?.physicsField?.strength = CGFloat(accelStrength * 35)
            
        }
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let scnView = self.view as! SCNView
        
        if coinsAreFlowing {
            timer.invalidate()
            timer = Timer()
            coinsAreFlowing = false
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                scnView.scene?.rootNode.addChildNode(self.newCoin())
            }
            coinsAreFlowing = true
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
        coinNode.position = SCNVector3(x: 0.0, y: 2.0, z: 0.0)
        
        let coinPhysicsShape = SCNPhysicsShape(geometry: coin, options: nil)
        coinNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: coinPhysicsShape)
        coinNode.physicsBody?.mass = 1.0
        coinNode.physicsBody?.friction = 0.5
        coinNode.physicsBody?.rollingFriction = 0.2
        coinNode.physicsBody?.damping = 0.1
        coinNode.physicsBody?.angularDamping = 0.25
        
        let randomPerc = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let coinTorque = SCNVector4(x: Float(randomPerc - randomPerc/2), y: Float(randomPerc - randomPerc/2), z: Float(randomPerc - randomPerc/2), w: 1.0)
        coinNode.physicsBody?.applyTorque(coinTorque, asImpulse: true)
        
//        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
//            coinNode.physicsBody?.type = .static
//        }
        
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


