//
//  Mocked.swift
//  NodesMap iOS
//
//  Created by Maciej Chmielewski on 06.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

extension Map {
    static func mocked() -> Map {
        let me = Map{_, _ in false}
        
//        let node1 = Node(name: "foldback", interfaces: [
//            Interface(name: "in", model: "in"),
//            Interface(name: "out", model: "out"),
//            Interface(name: "treshold", model: "out")
//            ], model: "foldback")
//
//        let node2 = Node(name: "osc", interfaces: [
//            Interface(name: "out", model: "out"),
//            Interface(name: "fre", model: "out"),
//            Interface(name: "amp", model: "out")
//            ], model: "osc")
//
//        node2.sprite.position = CGPoint(x: -200, y: 0)
//
//        for node in [node1, node2] {
//            me.addNode(node)
//        }
        return me
    }
}
