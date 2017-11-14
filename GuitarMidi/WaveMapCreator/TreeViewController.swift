//
//  TreeViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 14.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class TreeViewController: UITableViewController {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nestMargin = CGFloat(20)
        
        let flatTreeElement = flatTree[indexPath.row]
        
        switch flatTreeElement.element {
        case .leaf(let leaf, let action):
            let leafCell = tableView.dequeueReusableCell(withIdentifier: "LeafCell") as! LeafCell
            leafCell.label.text = leaf.name
            leafCell.leadingConstraint.constant = nestMargin * CGFloat(flatTreeElement.nest)
            leafCell.selectAction = {action.select()}
            leafCell.pickAction = {action.pick()}
            return leafCell
        case .branch(let branch, let elements, _):
            let branchCell = tableView.dequeueReusableCell(withIdentifier: "BranchCell") as! BranchCell
            branchCell.label.text = "\(branch.name) (\(elements.count))"
            branchCell.leadingConstraint.constant = nestMargin * CGFloat(flatTreeElement.nest)
            branchCell.expandButton.setTitle(branch.open ? "-" : "+", for: .normal)
            branchCell.expandAction = { [weak self] in
                branch.open = !branch.open
                self?.refreshView()
            }
            return branchCell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flatTree.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let flatTreeElement = flatTree[indexPath.row]
        switch flatTreeElement.element {
        case .leaf(_, let action): action.select()
        case .branch(_, _, let action): action()
        }
    }
}

class LeafCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
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

class BranchCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandButton: UIButton!
    
    var expandAction: (() -> ())?
    
    @IBAction func expandButtonAction(sender: Any?) {
        expandAction?()
    }
}
