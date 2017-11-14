//
//  Map.swift
//  NodesMap iOS
//
//  Created by Maciej Chmielewski on 05.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import SpriteKit

public typealias ConnectionEndpoint = (Node, Interface)

public final class Map {
    static func makeLineSprite() -> SKShapeNode {
        let line = SKShapeNode(rect: CGRect(x: 0, y: 1, width: 1, height: 1000))
        return line
    }
    
    private let connect: (ConnectionEndpoint, ConnectionEndpoint) -> Bool
    private let breakConnection: (ConnectionEndpoint, ConnectionEndpoint) -> Bool
    private var state = State.none
    public var nodes: [Node] = []
    public var connections: [(ConnectionEndpoint, ConnectionEndpoint, SKShapeNode)] = []
    public var select: ((Node) -> ())?
    
    private lazy var draggingLineNode: SKShapeNode = {
        Map.makeLineSprite()
    }()
    
    private(set) lazy var scene: SKScene  = {
        let scene = SKNode.unarchiveFromFile(file: "Scene") as! SpriteScene
        
        scene.interaction = { [weak self] in
            switch $0 {
            case .on(let location): self?.on(location: location)
            case .drag(let location): self?.drag(location: location)
            case .off(let location): self?.off(location: location)
            }
        }
        
        return scene
    }()
    
    public init(connect: @escaping (ConnectionEndpoint, ConnectionEndpoint) -> Bool, breakConnection: @escaping (ConnectionEndpoint, ConnectionEndpoint) -> Bool) {
        self.connect = connect
        self.breakConnection = breakConnection
    }
    
    public func addNode(_ node: Node) {
        nodes.append(node)
        scene.addChild(node.sprite)
    }
    
    public func connect(lhs: ConnectionEndpoint, rhs: ConnectionEndpoint) {
        if connect(lhs, rhs) {
            let connectionSprite = Map.makeLineSprite()
            scene.addChild(connectionSprite)
            connections.append((lhs, rhs, connectionSprite))
            updateConnections()
        }
    }
    
    private func on(location: CGPoint) {
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
                    state = .connecting((node, interface))
                    scene.addChild(draggingLineNode)
                }
            }
        }
    }
    
    private func drag(location: CGPoint) {
        if case .dragging(let node) = state {
            node.sprite.position = location
            updateConnections()
        }
        
        if case .connecting(let node, let interface) = state {
            let interfaceRect = node.frameForInterface(interface: interface).moved(by: node.sprite.position)
            let draggingOrigin = CGPoint(x: interfaceRect.minX, y: interfaceRect.minY + 10)
            let draggingEnd = location
            setLine(line: draggingLineNode, from: draggingOrigin, to: draggingEnd)
        }
    }
    
    private func setLine(line: SKShapeNode, from: CGPoint, to: CGPoint) {
        line.yScale = to.distance(to: from) / 1000
        line.position = to
        line.zRotation = atan2(from.y - to.y, from.x - to.x) + CGFloat(Float.pi / -2)
    }
    
    private func off(location: CGPoint) {
        if case .dragging(let onLocation) = state {
            for node in nodes {
                let nodeRect = node.frameForName().moved(by: node.sprite.position)
                if nodeRect.contains(location) {
                    select?(node)
                }
            }
        }
        
        if case .none = state {
            let tapRadius = CGFloat(20)
            let tapNode = SKShapeNode(ellipseIn: CGRect(x: location.x - tapRadius, y: location.y - tapRadius, width: tapRadius * 2, height: tapRadius * 2))
            scene.addChild(tapNode)
            var i = 0
            var indexToRemove: Int?
            for connection in connections {
                defer {
                    i += 1
                }
                if connection.2.intersects(tapNode) {
                    if breakConnection(connection.0, connection.1) {
                        indexToRemove = i
                        connection.2.removeFromParent()
                    }
                }
            }
            if let indexToRemove = indexToRemove {
                connections.remove(at: indexToRemove)
            }
            tapNode.removeFromParent()
        }
        
        for node in nodes {
            for interface in node.interfaces {
                let interfaceRect = node.frameForInterface(interface: interface).moved(by: node.sprite.position)
                if interfaceRect.contains(location) {
                    if case .connecting(let originEndpoint) = state {
                        let secondEndpoint = (node, interface)
                        self.connect(lhs: originEndpoint, rhs: secondEndpoint)
                    }
                }
            }
        }
        
        state = .none
        draggingLineNode.removeFromParent()
    }
    
    private func updateConnections() {
        for connection in connections {
            setLine(line: connection.2,
                    from: connection.0.0.frameForInterface(interface: connection.0.1).moved(by: connection.0.0.sprite.position).origin,
                    to: connection.1.0.frameForInterface(interface: connection.1.1).moved(by: connection.1.0.sprite.position).origin)
        }
    }
}

extension Map {
    public enum State {
        case none
        case dragging(Node)
        case connecting(ConnectionEndpoint)
    }
}

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = Bundle(for: Map.self).path(forResource: file, ofType: "sks") {
            
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! SKNode
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}
