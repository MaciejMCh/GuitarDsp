//
//  GameViewController.swift
//  NodesMap macOS
//
//  Created by Maciej Chmielewski on 29.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Cocoa
import SpriteKit

public class MapViewController: NSViewController {
    public var map: Map!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = map.scene
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

}

