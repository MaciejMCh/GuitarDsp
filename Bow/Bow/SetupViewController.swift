//
//  SetupViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 07.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarDsp
import GuitarMidi

class SetupViewController: NSViewController {
    fileprivate var setup: Setup!
    var looperEffectViewController: LooperEffectViewController!
    var boardViewController: BoardViewController!
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let looperEffectViewController = segue.destinationController as? LooperEffectViewController {
            self.looperEffectViewController = looperEffectViewController
            looperEffectViewController.looperEffect = setup.looperEffect
        }
        if let boardViewController = segue.destinationController as? BoardViewController {
            self.boardViewController = boardViewController
            let initialBoard = Storable(origin: .orphan, jsonRepresentable: BoardPrototype(board: Board()))
            let boardViewControllerSetup = BoardViewController.Setup(board: initialBoard, effectsFactory: setup.effectsFactory) { [weak self] in
                self?.updateBoard(boardPrototype: $0)
            }
            boardViewController.setup(setup: boardViewControllerSetup)
            updateBoard(boardPrototype: boardViewController.boardPrototype)
        }
    }
    
    fileprivate func updateBoard(boardPrototype: BoardPrototype) {
        setup.boardChange(boardPrototype.makeBoard() + setup.looperEffect)
    }
}

extension SetupViewController {
    struct Setup {
        let looperEffect: LooperEffect
        let effectsFactory: EffectsFacory
        let boardChange: (Board) -> ()
    }
    
    func setup(setup: Setup) {
        self.setup = setup
    }
}
