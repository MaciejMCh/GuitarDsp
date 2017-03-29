//
//  EffectViewModel.swift
//  Bow
//
//  Created by Maciej Chmielewski on 29.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp


struct EffectViewModel {
    let effect: Effect
    
    func name() -> String {
        switch effect {
        case is ReverbEffect: return "reverb"
        default:
            assert(false)
            return ""
        }
    }
    
    func color() -> NSColor {
        switch effect {
        case is ReverbEffect: return NSColor(calibratedRed: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        default:
            assert(false)
            return .clear
        }
    }
}
