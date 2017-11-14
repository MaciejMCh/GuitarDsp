//
//  TreeViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 22.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class TreeViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    
    var tree: TreeElement!
    
    private var flatTree: [FlatTreeElement] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshView()
    }
    
    private func refreshView() {
        flatTree = FlatTreeElement.make(root: tree)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let nestMargin = CGFloat(20)
        
        let flatTreeElement = flatTree[row]
        
        switch flatTreeElement.element {
        case .leaf(let leaf, let action):
            let leafRowView = tableView.make(withIdentifier: "LeafRowView", owner: nil) as! LeafRowView
            leafRowView.label.stringValue = leaf.name
            leafRowView.leadingConstraint.constant = nestMargin * CGFloat(flatTreeElement.nest)
            leafRowView.selectAction = {action.select()}
            leafRowView.pickAction = {action.pick()}
            return leafRowView
        case .branch(let branch, let elements, _):
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
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let flatTreeElement = flatTree[row]
        switch flatTreeElement.element {
        case .leaf(_, let action): action.select()
        case .branch(_, _, let action): action()
        }
        return true
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
