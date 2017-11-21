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
    private let remove: (Node) -> Bool
    private var state: State = .none
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
    
    public init(connect: @escaping (ConnectionEndpoint, ConnectionEndpoint) -> Bool,
                breakConnection: @escaping (ConnectionEndpoint, ConnectionEndpoint) -> Bool,
                remove: @escaping (Node) -> Bool) {
        self.connect = connect
        self.breakConnection = breakConnection
        self.remove = remove
    }
    
    public func startSelecting() {
        state = .willSelect
    }
    
    public func startDeleting() {
        state = .willDelete
    }
    
    public func startAddingNode(_ node: Node) {
        state = .willAdd(node)
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
    
    private func select(p1: CGPoint, p2: CGPoint) -> (nodes: [Node], rect: CGRect) {
        let originX = min(p1.x, p2.x)
        let originY = min(p1.y, p2.y)
        let width = max(p1.x, p2.x) - originX
        let height = max(p1.y, p2.y) - originY
        let selectionRect = CGRect(x: originX, y: originY, width: width, height: height)
        
        let selectedNodes = nodes.filter{selectionRect.contains($0.sprite.frame) || selectionRect.intersects($0.sprite.frame)}
        
        return (selectedNodes, selectionRect)
    }
    
    private func styleSelected(sprite: SKNode) {
        (sprite as? SKShapeNode)?.strokeColor = .green
    }
    
    private func styleRegular(sprite: SKNode) {
        (sprite as? SKShapeNode)?.strokeColor = .white
    }
    
    private func removeNode(_ node: Node) {
        guard remove(node) else {return}
        nodes = nodes.filter{$0.model.id != node.model.id}
        node.sprite.removeFromParent()
        
        var connectionsIndicesToBreak: [Int] = []
        var i = 0
        for connection in connections {
            defer {
                i += 1
            }
            if connection.0.0.model.id == node.model.id || connection.1.0.model.id == node.model.id {
                connectionsIndicesToBreak.append(i)
                connection.2.removeFromParent()
            }
        }
        
        for connectionIndexToBreak in connectionsIndicesToBreak.sorted().reversed() {
            connections.remove(at: connectionIndexToBreak)
        }
    }
    
    private func on(location: CGPoint) {
        switch state {
        case .willAdd(let node):
            addNode(node)
            let gridLocation = CGPoint(x: allignToGrid(location.x), y: allignToGrid(location.y))
            node.sprite.position = gridLocation
            state = .dragging(origin: gridLocation, node: node)
        case .selected(let nodes):
            for node in nodes {
                if node.sprite.frame.contains(location) {
                    state = .draggingSelection(origin: location, nodes: nodes)
                    break
                }
            }
        case .willSelect:
            let selectionNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 200, height: 200))
            selectionNode.fillColor = .init(white: 1, alpha: 0.4)
            selectionNode.strokeColor = .white
            selectionNode.setScale(0.0001)
            scene.addChild(selectionNode)
            state = .selecting(origin: location, selectionNode: selectionNode)
        case .none:
            // start drag single node
            for node in nodes {
                let nodeRect = node.frameForName().moved(by: node.sprite.position)
                if nodeRect.contains(location) {
                    state = .dragging(origin: CGPoint(x: allignToGrid(location.x), y: allignToGrid(location.y)), node: node)
                }
            }
            
            // start connecting interfaces
            for node in nodes {
                for interface in node.interfaces {
                    let interfaceRect = node.frameForInterface(interface: interface).moved(by: node.sprite.position)
                    if interfaceRect.contains(location) {
                        state = .connecting((node, interface))
                        scene.addChild(draggingLineNode)
                    }
                }
            }
        default: break
        }
    }
    
    private func allignToGrid(_ float: CGFloat) -> CGFloat {
        let gridSize: CGFloat = 20
        return CGFloat(Int((float) / gridSize)) * gridSize
    }
    
    private func drag(location: CGPoint) {
        switch state {
        case .draggingSelection(let origin, let nodes):
            let dragDiffX = allignToGrid(location.x - origin.x)
            let dragDiffY = allignToGrid(location.y - origin.y)
            
            guard abs(dragDiffX) + abs(dragDiffY) > 0 else {return}
            
            for node in nodes {
                node.sprite.position = CGPoint(x: node.sprite.position.x + dragDiffX,
                                               y: node.sprite.position.y + dragDiffY)
            }
            
            state = .draggingSelection(origin: location, nodes: nodes)
            updateConnections()
        case .selecting(let origin, let selectionNode):
            let selection = self.select(p1: origin, p2: location)
            
            for node in nodes {
                styleRegular(sprite: node.sprite)
            }
            for selectedNode in selection.nodes {
                styleSelected(sprite: selectedNode.sprite)
            }
            
            selectionNode.position = selection.rect.origin
            selectionNode.xScale = selection.rect.size.width / 200
            selectionNode.yScale = selection.rect.size.height / 200
        case .dragging(let origin, let node):
            let dragDiffX = allignToGrid(location.x - origin.x)
            let dragDiffY = allignToGrid(location.y - origin.y)
            
            guard abs(dragDiffX) + abs(dragDiffY) > 0 else {return}
            
            node.sprite.position = CGPoint(x: node.sprite.position.x + dragDiffX,
                                           y: node.sprite.position.y + dragDiffY)
            
            state = .dragging(origin: location, node: node)
            updateConnections()
        case .connecting(let node, let interface):
            let interfaceRect = node.frameForInterface(interface: interface).moved(by: node.sprite.position)
            let draggingOrigin = CGPoint(x: interfaceRect.minX, y: interfaceRect.minY + 10)
            let draggingEnd = location
            setLine(line: draggingLineNode, from: draggingOrigin, to: draggingEnd)
        default: break
        }
    }
    
    private func off(location: CGPoint) {
        switch state {
        case .willDelete:
            for node in nodes {
                if node.sprite.frame.contains(location) {
                    removeNode(node)
                }
            }
            state = .none
        case .draggingSelection(let origin, let nodes):
            state = .selected(nodes)
        case .selected(let nodes):
            for node in nodes {
                styleRegular(sprite: node.sprite)
            }
            state = .none
        case .selecting(let origin, let selectionNode):
            selectionNode.removeFromParent()
            state = .selected(select(p1: origin, p2: location).nodes)
        case .dragging:
            for node in nodes {
                let nodeRect = node.frameForName().moved(by: node.sprite.position)
                if nodeRect.contains(location) {
                    select?(node)
                }
            }
            state = .none
        case .none:
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
        case .connecting(let originEndpoint):
            for node in nodes {
                for interface in node.interfaces {
                    let interfaceRect = node.frameForInterface(interface: interface).moved(by: node.sprite.position)
                    if interfaceRect.contains(location) {
                        let secondEndpoint = (node, interface)
                        self.connect(lhs: originEndpoint, rhs: secondEndpoint)
                    }
                }
            }
            state = .none
            draggingLineNode.removeFromParent()
        default:
            state = .none
        }
    }
    
    private func setLine(line: SKShapeNode, from: CGPoint, to: CGPoint) {
        line.yScale = to.distance(to: from) / 1000
        line.position = to
        line.zRotation = atan2(from.y - to.y, from.x - to.x) + CGFloat(Float.pi / -2)
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
        case dragging(origin: CGPoint, node: Node)
        case connecting(ConnectionEndpoint)
        case willSelect
        case selecting(origin: CGPoint, selectionNode: SKNode)
        case selected([Node])
        case draggingSelection(origin: CGPoint, nodes: [Node])
        case willDelete
        case willAdd(Node)
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
