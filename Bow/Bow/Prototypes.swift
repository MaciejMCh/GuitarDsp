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
        effectPrototypes = []
    }
}

extension EffectPrototype {
    enum Kind: String {
        case reverb
        case harmonizer
        case phaseVocoder
        case delay
        case amp
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
