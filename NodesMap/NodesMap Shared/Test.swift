//
//  Test.swift
//  NodesMap iOS
//
//  Created by Maciej Chmielewski on 03.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

class Node {
    var name: String
    let interfaces: [Interface]
    var sprite: SKNode!
    
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
    
    init(name: String, interfaces: [Interface]) {
        self.name = name
        self.interfaces = interfaces
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

class Interface {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}
