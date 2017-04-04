//
//  BoardViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 28.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarDsp

class BoardViewController: NSViewController {
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var orderViewHeightConstraint: NSLayoutConstraint!
    
    var board: Storable<BoardPrototype>!
    var effectsFactory: EffectsFacory!
    
    var effectsOrderViewController: EffectsOrderViewController!
    
    func changeBoard(board: Storable<BoardPrototype>) {
        self.board = board
        clearEffectControllers()
        addEffectControllers()
        setupOrderChangeViewController()
        layoutEffectOrderView()
    }
    
    func setupOrderChangeViewController() {
        effectsOrderViewController.effectsFactory = effectsFactory
        effectsOrderViewController.setupWithEffects(effects: board.jsonRepresentable.effectPrototypes)
        effectsOrderViewController.structureChange.subscribe { [weak self] event in
            switch event {
            case .next(let effects): self?.effectsStructureUpdated(effects: effects)
            default: break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addEffectControllers()
        layoutEffectOrderView()
        
        bowMenu?.saveMenuItem.target = self
        bowMenu?.saveMenuItem.action = #selector(saveAction)
        bowMenu?.openMenuItem.target = self
        bowMenu?.openMenuItem.action = #selector(openAction)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let effetcsOrderViewController = segue.destinationController as? EffectsOrderViewController {
            self.effectsOrderViewController = effetcsOrderViewController
            setupOrderChangeViewController()
        }
    }
    
    func saveAction() {
        switch board.origin {
        case .orphan: presentViewControllerAsModalWindow(TagPickerController.withCompletion(completion: { [weak self] (tag) in
            guard let wSelf = self else {return}
            let newBoard = Storable<BoardPrototype>(origin: .selfMade(identity: Storage.Identity(id: tag)), jsonRepresentable: wSelf.board.jsonRepresentable)
            newBoard.update()
            wSelf.board = newBoard
        }))
        default: board.update()
        }
    }
    
    func openAction() {
        let searchViewController = SearchViewController.make()
        searchViewController.searchForBoards { [weak self] in
            self?.changeBoard(board: $0)
        }
        presentViewControllerAsModalWindow(searchViewController)
    }
    
    private func effectsStructureUpdated(effects: [EffectPrototype]) {
        board.jsonRepresentable.effectPrototypes = effects
        clearEffectControllers()
        addEffectControllers()
        layoutEffectOrderView()
    }
    
    private func layoutEffectOrderView() {
        orderViewHeightConstraint.constant = CGFloat(board.jsonRepresentable.effectPrototypes.count) * EffectsOrderViewModel().rowHeight + EffectsOrderViewModel().addButtonheight
    }
    
    func clearEffectControllers() {
        let children = childViewControllers
        for child in children {
            if let effectChild = child as? EffectViewController {
                effectChild.removeFromParentViewController()
            }
        }
        gridView.clear()
    }
    
    func addEffectControllers() {
        var i = 0
        for effectPrototype in board.jsonRepresentable.effectPrototypes {
            let effectController = EffectViewController.make()
            effectController.effectPrototype = effectPrototype
            addChildViewController(effectController)
            insertViewInSocket(viewToInsert: effectController.view, index: i)
            i += 1
        }
    }
    
    func insertViewInSocket(viewToInsert: NSView, index: Int) {
        gridView.addView(view: viewToInsert)
        var frame = viewToInsert.frame
        frame.origin.x = CGFloat(index) * CGFloat(300)
        frame.origin.y = 100
        frame.size.height = EffectViewModel.viewHeight
        viewToInsert.frame = frame
    }
}
