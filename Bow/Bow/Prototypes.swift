//
//  Prototypes.swift
//  Bow
//
//  Created by Maciej Chmielewski on 04.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

struct BoardPrototype {
    var effectPrototypes: [EffectPrototype]
    
    init(board: Board) {
        effectPrototypes = board.effects.map{EffectPrototype(effect: $0)}
    }
    
    init(effectPrototypes: [EffectPrototype]) {
        self.effectPrototypes = effectPrototypes
    }
    
    func makeBoard() -> Board {
        let board = Board()
        board.effects = effectPrototypes.map{$0.effect}
        return board
    }
}

extension EffectPrototype {
    enum Kind: String {
        case reverb
        case harmonizer
        case phaseVocoder
        case delay
        case amp
        case compressor
        case bitCrusher
        case vibe
    }
}

struct EffectPrototype {
    static var effectsFactory: EffectsFacory!
    let kind: Kind
    let configuration: JsonObject
    let effect: Effect
    
    init(effect: Effect) {
        self.effect = effect
        kind = EffectPrototype.kind(effect: effect)
        configuration = EffectPrototype.configuration(effect: effect)
    }
}

extension Board {
    static func +(lhs: Board, rhs: Effect) -> Board {
        let board = Board()
        var effects = lhs.effects
        effects?.append(rhs)
        board.effects = effects
        return board
    }
}
