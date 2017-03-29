//
//  EffectViewModel.swift
//  Bow
//
//  Created by Maciej Chmielewski on 29.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

extension Float {
    static var goldenRatio: Float {
        return 1.61803398875
    }
}

struct EffectViewModel {
    let effect: Effect
    static let viewHeight: CGFloat = 210
    
    func name() -> String {
        switch effect {
        case is ReverbEffect: return "reverb"
        case is HarmonizerEffect: return "harmonizer"
        default:
            assert(false)
            return ""
        }
    }
    
    func color() -> NSColor {
        switch effect {
        case is ReverbEffect: return NSColor(calibratedRed: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        case is HarmonizerEffect: return NSColor(calibratedRed: 74.0 / 255.0, green: 226.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
        default:
            assert(false)
            return .clear
        }
    }
}

struct SliderViewModel {
    let sliderWidth: CGFloat = EffectViewModel.viewHeight / CGFloat(Float.goldenRatio)
}
