//
//  GameScene.swift
//  NodesMap Shared
//
//  Created by Maciej Chmielewski on 29.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import SpriteKit

extension CGRect {
    func moved(by: CGPoint) -> CGRect {
        return CGRect(x: minX + by.x, y: minY + by.y, width: width, height: height)
    }
}

extension CGPoint {
    func distance(to p:CGPoint) -> CGFloat {
        return sqrt(pow(x - p.x, 2) + pow(y - p.y, 2))
    }
}

class GameScene: SKScene {
    
    
    fileprivate var label : SKLabelNode?
    fileprivate var spinnyNode : SKShapeNode?
    
    lazy var draggingLineNode: SKShapeNode = {
        let line = SKShapeNode(rect: CGRect(x: 0, y: 1, width: 1, height: 1000))
        return line
    }()
    
    var nodes: [Node] = []
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    enum State {
        case none
        case dragging(Node)
        case connecting(Node, Interface)
    }
    
    var state = State.none
    
    func on(location: CGPoint) {
        for node in nodes {
            let nodeRect = node.frameForName().moved(by: node.sprite.position)
            if nodeRect.contains(location) {
                state = .dragging(node)
            }
        }
        
        for node in nodes {
            for interface in node.interfaces {
                let interfaceRect = node.frameForInterface(interface: interface).moved(by: node.sprite.position)
                if interfaceRect.contains(location) {
                    state = .connecting(node, interface)
                    addChild(draggingLineNode)
                }
            }
        }
    }
    
    func drag(location: CGPoint) {
        if case .dragging(let node) = state {
            node.sprite.position = location
            return
        }
        
        if case .connecting(let node, let interface) = state {
            let interfaceRect = node.frameForInterface(interface: interface).moved(by: node.sprite.position)
            let draggingOrigin = CGPoint(x: interfaceRect.minX, y: interfaceRect.minY + 10)
            let draggingEnd = location
            setLine(line: draggingLineNode, from: draggingOrigin, to: draggingEnd)
        }
    }
    
    func setLine(line: SKShapeNode, from: CGPoint, to: CGPoint) {
        draggingLineNode.yScale = to.distance(to: from) / 1000
        draggingLineNode.position = to
        draggingLineNode.zRotation = atan2(from.y - to.y, from.x - to.x) + CGFloat(Float.pi / -2)
    }
    
    func off(location: CGPoint) {
        state = .none
        draggingLineNode.removeFromParent()
    }
    
    func setUpScene() {
        let node = Node(name: "foldback", interfaces: [
            Interface(name: "in"),
            Interface(name: "out"),
            Interface(name: "treshold")
            ])
        
        addChild(node.sprite)
        
        nodes.append(node)
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif

    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        on(location: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        drag(location: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        off(location: event.location(in: self))
    }

}
#endif

