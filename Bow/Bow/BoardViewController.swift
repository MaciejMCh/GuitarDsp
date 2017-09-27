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
    
    private var setup: Setup!
    
    var boardPrototype: BoardPrototype {
        return setup.board.jsonRepresentable
    }
    
    var effectsOrderViewController: EffectsOrderViewController!
    
    func setup(setup: Setup) {
        self.setup = setup
    }
    
    func changeBoard(board: Storable<BoardPrototype>) {
        setup.board = board
        clearEffectControllers()
        addEffectControllers()
        setupOrderChangeViewController()
        layoutEffectOrderView()
        setup.prototypeChanged(setup.board.jsonRepresentable)
    }
    
    func setupOrderChangeViewController() {
        effectsOrderViewController.effectsFactory = setup.effectsFactory
        effectsOrderViewController.setupWithEffects(effects: setup.board.jsonRepresentable.effectPrototypes)
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
        
        bowMenu?.newMenuItem.target = self
        bowMenu?.newMenuItem.action = #selector(newAction)
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
    
    func newAction() {
        changeBoard(board: Storable(origin: .orphan, jsonRepresentable: BoardPrototype(board: Board())))
    }
    
    func saveAction() {
        switch setup.board.origin {
        case .orphan: presentViewControllerAsModalWindow(TagPickerController.withCompletion(completion: { [weak self] (tag) in
            guard let wSelf = self else {return}
            let newBoard = Storable<BoardPrototype>(origin: .selfMade(identity: Storage.Identity(id: tag)), jsonRepresentable: wSelf.setup.board.jsonRepresentable)
            newBoard.update()
            wSelf.setup.board = newBoard
        }))
        default: setup.board.update()
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
        setup.board.jsonRepresentable.effectPrototypes = effects
        clearEffectControllers()
        addEffectControllers()
        layoutEffectOrderView()
        setup.prototypeChanged(BoardPrototype(effectPrototypes: effects))
    }
    
    private func layoutEffectOrderView() {
        orderViewHeightConstraint.constant = CGFloat(setup.board.jsonRepresentable.effectPrototypes.count) * EffectsOrderViewModel().rowHeight + EffectsOrderViewModel().addButtonheight
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
        for effectPrototype in setup.board.jsonRepresentable.effectPrototypes {
            let effectController: NSViewController
            switch effectPrototype.instance {
            case .channelPlayer(let channelPlayerEffect):
                let channelPlayerTileController = ChannelPlayerTileController.make()
                channelPlayerTileController.channelPlayerEffect = channelPlayerEffect
                effectController = channelPlayerTileController
            default:
                let effectViewController = EffectViewController.make()
                effectViewController.effectPrototype = effectPrototype
                effectController = effectViewController
            }
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

extension BoardViewController {
    struct Setup {
        var board: Storable<BoardPrototype>
        let effectsFactory: EffectsFacory
        let prototypeChanged: (BoardPrototype) -> Void
    }
}
