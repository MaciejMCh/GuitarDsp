//
//  TreeViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 22.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

indirect enum TreeElement<Leaf> {
    class Branch {
        let name: String
        var open = false
        
        init(name: String) {
            self.name = name
        }
    }
    
    struct Action {
        let select: (Leaf) -> Void
        let pick: (Leaf) -> Void
    }
    
    case branch(Branch, elements: [TreeElement<Leaf>])
    case leaf(Leaf, action: Action)
    
    static func fromRootElements(_ elements: [Any]) -> TreeElement<Leaf> {
        let select: (Leaf) -> Void = {_ in}
        let pick: (Leaf) -> Void = {_ in}
        
        return makeTreeElement(element: ("root", elements), action: Action(select: select, pick: pick))
    }
    
    private static func makeTreeElement(element: Any, action: Action) -> TreeElement<Leaf> {
        if let leafValue = element as? Leaf {
            return .leaf(leafValue, action: action)
        }
        if let branch = element as? (String, [Any]) {
            return .branch(.init(name: branch.0), elements: branch.1.map{makeTreeElement(element: $0, action: action)})
        }
        return "" as! TreeElement<Leaf>
    }
}

struct FlatTreeElement<Leaf> {
    let element: TreeElement<Leaf>
    let nest: Int
    
    static func make(root: TreeElement<Leaf>) -> [FlatTreeElement<Leaf>] {
        return flatten(treeElement: root, nestLevel: 0)
    }
    
    private static func flatten(treeElement: TreeElement<Leaf>, nestLevel: Int) -> [FlatTreeElement<Leaf>] {
        switch treeElement {
        case .leaf: return [FlatTreeElement(element: treeElement, nest: nestLevel)]
        case .branch(let branch, let elements):
            var result: [FlatTreeElement<Leaf>] = [FlatTreeElement(element: treeElement, nest: nestLevel)]
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

class TreeViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    
    var tree: TreeElement<String> = {
        let hierarchy: [Any] =
            [
                "808",
                ("kicks", ["k1", "k2", "k3", "k4"]),
                ("hhs", ["h1", "h2"]),
                ("crashes", ["c1", "c2", "c3"])
        ]
        let root = TreeElement<String>.fromRootElements(hierarchy)
        return root
    }()
    
    private var flatTree: [FlatTreeElement<String>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshView()
    }
    
    private func refreshView() {
        flatTree = FlatTreeElement<String>.make(root: tree)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let nestMargin = CGFloat(20)
        
        let flatTreeElement = flatTree[row]
        
        switch flatTreeElement.element {
        case .leaf(let leaf, let action):
            let leafRowView = tableView.make(withIdentifier: "LeafRowView", owner: nil) as! LeafRowView
            leafRowView.label.stringValue = leaf
            leafRowView.leadingConstraint.constant = nestMargin * CGFloat(flatTreeElement.nest)
            leafRowView.selectAction = {action.select(leaf)}
            leafRowView.pickAction = {action.pick(leaf)}
            return leafRowView
        case .branch(let branch, let elements):
            let branchRowView = tableView.make(withIdentifier: "BranchRowView", owner: nil) as! BranchRowView
            branchRowView.label.stringValue = "\(branch.name) (\(elements.count))"
            branchRowView.leadingConstraint.constant = nestMargin * CGFloat(flatTreeElement.nest)
            branchRowView.expandButton.title = branch.open ? "-" : "+"
            branchRowView.expandAction = { [weak self] in
                branch.open = !branch.open
                self?.refreshView()
            }
            return branchRowView
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return flatTree.count
    }
}

class LeafRowView: NSTableRowView {
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    var selectAction: (() -> ())?
    var pickAction: (() -> ())?
    
    @IBAction func singleClickAction(sender: Any?) {
        selectAction?()
    }
    
    @IBAction func doubleClickAction(sender: Any?) {
        pickAction?()
    }
}

class BranchRowView: NSTableRowView {
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandButton: NSButton!
    
    var expandAction: (() -> ())?
    
    @IBAction func expandButtonAction(sender: Any?) {
        expandAction?()
    }
}
