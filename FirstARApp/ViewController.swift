//
//  ViewController.swift
//  FirstARApp
//
//  Created by Rashmeet Singh on 2020-05-29.
//  Copyright © 2020 Rashmeet Singh. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        // Override default configs
        setupARView()
        
        // Add gesture recongnization - To sense taps on the screen
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        
    }
    
    // Custom Configuration to override the auto configurations
    func setupARView(){
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    // In line 24 we are using the selector syntax due to which we have to use the objc flag
    @objc
    
    func handleTap(recognizer: UITapGestureRecognizer){
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        // To put an object in the scene, we need to attach it to an anchor. We use the ARAnchor class and name field has the name of the asset
        if let firstResult = results.first {
            let anchor = ARAnchor (name: "shiba", transform: firstResult.worldTransform)
            // Add the above created anchor to the session
            arView.session.add(anchor: anchor)
        }
        else{
            print("Cannot find a surface to place object")
        }
        
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor){
        // Create Model Entity
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        // Give ability to move or rotate the model in the scene
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        // Create Anchor Entity
        let anchorEntity = AnchorEntity(anchor: anchor)
        // Add model entity to anchor entity
        anchorEntity.addChild(entity)
        // Add it to the scene
        arView.scene.addAnchor(anchorEntity)
        
    }
}


extension ViewController: ARSessionDelegate{
    func session(_ session: ARSession, didAdd anchors:[ARAnchor]){
        for anchor in anchors{
            if let name = anchor.name, name == "shiba"{
                placeObject(named: name, for: anchor)
            }
        }
    }
}
