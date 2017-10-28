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
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.light?.intensity = 1000.0
        lightNode.position = SCNVector3(x: 5, y: 5, z: 5)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.5, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        // configure coin node
        let coin = SCNCylinder(radius: 2, height: 0.2)
        coin.firstMaterial?.lightingModel = .physicallyBased
        coin.firstMaterial?.diffuse.contents = UIColor(red: 0.85, green: 0.82, blue: 0.58, alpha: 1.0)
//        coin.firstMaterial?.roughness.contents = 0.9
        coin.firstMaterial?.metalness.contents = 1.0
        
        let coinFaceImage = UIImage(named: "art.scnassets/coin_normal_map.png")
        coin.firstMaterial?.normal.contents = coinFaceImage
        
        let coinNode = SCNNode(geometry: coin)
        scene.rootNode.addChildNode(coinNode)
        
        let spin = SCNAction.rotateBy(x: CGFloat(Float.pi), y: 0.0, z: 0.0, duration: 1.0)
        let action = SCNAction.repeatForever(spin)
        coinNode.runAction(action)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.96, alpha: 1.0)
//        scnView.autoenablesDefaultLighting = true
        
        // add a tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        scnView.addGestureRecognizer(tapGesture)
    }
    
//    @objc
//    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
//        // retrieve the SCNView
//        let scnView = self.view as! SCNView
//
//        // check what nodes are tapped
//        let p = gestureRecognize.location(in: scnView)
//        let hitResults = scnView.hitTest(p, options: [:])
//        // check that we clicked on at least one object
//        if hitResults.count > 0 {
//            // retrieved the first clicked object
//            let result = hitResults[0]
//
//            // get its material
//            let material = result.node.geometry!.firstMaterial!
//
//            // highlight it
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 0.5
//
//            // on completion - unhighlight
//            SCNTransaction.completionBlock = {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 0.5
//
//                material.emission.contents = UIColor.black
//
//                SCNTransaction.commit()
//            }
//
//            material.emission.contents = UIColor.red
//
//            SCNTransaction.commit()
//        }
//    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
