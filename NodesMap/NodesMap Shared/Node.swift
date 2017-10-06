//
//  Node.swift
//  NodesMap iOS
//
//  Created by Maciej Chmielewski on 06.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import SpriteKit

public class Node {
    public var name: String
    let interfaces: [Interface]
    var sprite: SKNode!
    public var model: Any
    
    private let width = CGFloat(140)
    let rowHeight = CGFloat(40)
    let nameHeight = CGFloat(40)
    
    func frameForInterface(interface: Interface) -> CGRect {
        let index = interfaces.map{$0.name}.index(of: interface.name)!
        return CGRect(x: 5, y: rowHeight * CGFloat(index), width: width, height: rowHeight)
    }
    
    func frameForName() -> CGRect {
        return CGRect(x: 0,
                      y: CGFloat(interfaces.count) * rowHeight,
                      width: width,
                      height: nameHeight)
    }
    
    public init(name: String, interfaces: [Interface], model: Any) {
        self.name = name
        self.interfaces = interfaces
        self.model = model
        sprite = makeSprite()
    }
    
    private func makeSprite() -> SKNode {
        let container = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: nameHeight + CGFloat(interfaces.count) * rowHeight))
        
        let nameNode = SKLabelNode(text: name)
        let nameRect = frameForName()
        nameNode.position = CGPoint(x: nameRect.midX, y: nameRect.midY)
        nameNode.horizontalAlignmentMode = .center
        container.addChild(nameNode)
        
        for Interface in interfaces {
            let labelNode = SKLabelNode(text: Interface.name)
            labelNode.position = frameForInterface(interface: Interface).origin
            labelNode.horizontalAlignmentMode = .left
            container.addChild(labelNode)
        }
        
        return container
    }
    
}

public class Interface {
    public var name: String
    public var model: Any
    
    public init(name: String, model: Any) {
        self.name = name
        self.model = model
    }
}
