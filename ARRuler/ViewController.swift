//
//  ViewController.swift
//  ARRuler
//
//  Created by Alejandro Serna Rodriguez on 2/14/20.
//  Copyright © 2020 Alejandro Serna Rodriguez. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

//MARK: - ARKit Rendering methods

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }

            dotNodes = [SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView) {

            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }

    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()

        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        dotGeometry.materials = [material]

        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(CGFloat(hitResult.worldTransform.columns.3.x), CGFloat(hitResult.worldTransform.columns.3.y), CGFloat(hitResult.worldTransform.columns.3.z))

        sceneView.scene.rootNode.addChildNode(dotNode)

        dotNodes.append(dotNode)

        if dotNodes.count >= 2 {
            calculate()
        }

//        let randomX = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
//        let randomY = Double((arc4random_uniform(10) + 11)) * (Double.pi/2)
//        let randomZ = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        
//        dotNode.runAction(SCNAction.rotateBy(x: 0, y: CGFloat(randomX * 5), z: 0, duration: 100))
    }

    func  calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]

        print(start.position)
        print(end.position)

        let a = pow(end.position.x - start.position.x, 2)
        let b = pow(end.position.y - start.position.y, 2)
        let c = pow(end.position.z - start.position.z, 2)

        let distance = abs(sqrt(a+b+c)*100)

        updateText("\(String(format: "%2.f", distance)) CM", atPosition: end.position)
    }

    func updateText(_ text: String, atPosition: SCNVector3) {

        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(atPosition.x, atPosition.y + 0.01, atPosition.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)

        sceneView.scene.rootNode.addChildNode(textNode)
    }

// MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.y))

            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]

            let planeNode = SCNNode()
            
            planeNode.geometry = plane
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
    
}
