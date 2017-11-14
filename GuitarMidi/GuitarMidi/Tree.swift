//
//  Tree.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 14.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

indirect enum TreeElement {
    class Branch {
        let name: String
        var open = false
        
        init(name: String) {
            self.name = name
        }
    }
    
    struct Action {
        let select: () -> Void
        let pick: () -> Void
    }
    
    case branch(Branch, elements: [TreeElement], action: () -> ())
    case leaf(LeafRepresentable, action: Action)
}

struct FlatTreeElement {
    let element: TreeElement
    let nest: Int
    
    static func make(root: TreeElement) -> [FlatTreeElement] {
        return flatten(treeElement: root, nestLevel: 0)
    }
    
    private static func flatten(treeElement: TreeElement, nestLevel: Int) -> [FlatTreeElement] {
        switch treeElement {
        case .leaf: return [FlatTreeElement(element: treeElement, nest: nestLevel)]
        case .branch(let branch, let elements, _):
            var result: [FlatTreeElement] = [FlatTreeElement(element: treeElement, nest: nestLevel)]
            if !branch.open {
                return result
            }
            for element in elements {
                result.append(contentsOf: flatten(treeElement: element, nestLevel: nestLevel + 1))
            }
            return result
        }
    }
}

protocol LeafRepresentable {
    var name: String {get}
}
