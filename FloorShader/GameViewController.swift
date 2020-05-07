//
//  GameViewController.swift
//  FloorShader
//
//  Created by Zack Brown on 05/05/2020.
//  Copyright © 2020 Zack Brown. All rights reserved.
//

import SceneKit

class GameViewController: NSViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard let sceneView = self.view as? SCNView else { fatalError("Invalid SCNView instance") }
        
        //
        //  create camera
        //
        
        let camera = SCNCamera()
        
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 15
        
        let cameraNode = SCNNode()
        
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 5.0, y: 0.0, z: 10.0)
        cameraNode.look(at: SCNVector3(x: 0.0, y: 0.0, z: 0.0))
        
        //
        //  create shader and floor plane
        //
        
        let program = SCNProgram()
        
        program.fragmentFunctionName = "floor_fragment"
        program.vertexFunctionName = "floor_vertex"
        program.delegate = self
        
        let floor = SCNPlane(width: 10, height: 10)
        
        floor.program = program
        
        let grid = SCNNode(geometry: floor)
        
        //
        //  setup scene and add child nodes
        //
        
        let boxNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
        
        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = .darkGray
        sceneView.autoenablesDefaultLighting = true
        sceneView.isPlaying = true
        
        sceneView.scene?.rootNode.addChildNode(grid)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        sceneView.scene?.rootNode.addChildNode(boxNode)
    }
}

extension GameViewController: SCNProgramDelegate {
    
    func program(_ program: SCNProgram, handleError error: Error) {
        
        print("SCNProgram error: \(error)")
    }
}
