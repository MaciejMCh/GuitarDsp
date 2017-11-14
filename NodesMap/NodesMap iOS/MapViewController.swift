//
//  GameViewController.swift
//  NodesMap iOS
//
//  Created by Maciej Chmielewski on 29.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import UIKit
import SpriteKit

public class MapViewController: UIViewController {
    public var map: Map!
    let camera = SKCameraNode()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = map.scene
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        panGestureRecognizer.minimumNumberOfTouches = 2
        skView.addGestureRecognizer(panGestureRecognizer)

        skView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pichAction)))
        
        map.scene.camera = camera
    }
    
    private var lastPanPosition = CGPoint.zero
    @objc func panAction(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let cameraPosition = camera.position
        let panPosition = panGestureRecognizer.location(in: nil)
        
        if panGestureRecognizer.state == .changed {
            let panPositionDiff = CGPoint(x: lastPanPosition.x - panPosition.x, y: lastPanPosition.y - panPosition.y)
            camera.position = CGPoint(x: cameraPosition.x + panPositionDiff.x, y: cameraPosition.y - panPositionDiff.y)
        }
        
        lastPanPosition = panPosition
    }
    
    private var pinchInitialScale = CGFloat(0)
    @objc func pichAction(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        switch pinchGestureRecognizer.state {
        case .began: pinchInitialScale = camera.yScale
        case .changed: camera.setScale(pinchInitialScale / pinchGestureRecognizer.scale)
        default: break
        }
    }
    
}
