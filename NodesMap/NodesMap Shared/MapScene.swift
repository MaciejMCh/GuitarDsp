//
//  GameScene.swift
//  NodesMap Shared
//
//  Created by Maciej Chmielewski on 29.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import SpriteKit

//class GameScene: SKScene {
//    fileprivate var label : SKLabelNode?
//    fileprivate var spinnyNode : SKShapeNode?
//
//    class func newGameScene() -> GameScene {
//        // Load 'GameScene.sks' as an SKScene.
//        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
//            print("Failed to load GameScene.sks")
//            abort()
//        }
//
//        // Set the scale mode to scale to fit the window
//        scene.scaleMode = .aspectFill
//
//        return scene
//    }
//
//    #if os(watchOS)
//    override func sceneDidLoad() {
//        self.setUpScene()
//    }
//    #else
//    override func didMove(to view: SKView) {
////        self.setUpScene()
//    }
//    #endif
//
//    func makeSpinny(at pos: CGPoint, color: SKColor) {
//        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
//            spinny.position = pos
//            spinny.strokeColor = color
//            self.addChild(spinny)
//        }
//    }
//
//    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//    }
//}
//
//#if os(iOS) || os(tvOS)
//// Touch-based event handling
//extension GameScene {
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//
//        for t in touches {
//            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
//        }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
//        }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
//        }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
//        }
//    }
//
//}
//#endif
//

extension SpriteScene {
    enum Interaction {
        case on(CGPoint)
        case drag(CGPoint)
        case off(CGPoint)
    }
}

#if os(OSX)
    // Mouse-based event handling
    public class SpriteScene: SKScene {
        var interaction: ((Interaction) -> Void)?
        
        public override func mouseDown(with event: NSEvent) {
            interaction?(.on(event.location(in: self)))
        }
        
        public override func mouseDragged(with event: NSEvent) {
            interaction?(.drag(event.location(in: self)))
        }
        
        public override func mouseUp(with event: NSEvent) {
            interaction?(.off(event.location(in: self)))
        }
    }
#endif
