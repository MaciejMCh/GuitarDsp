//
//  EffectViewModel.swift
//  Bow
//
//  Created by Maciej Chmielewski on 29.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import HexColors

extension Float {
    static var goldenRatio: Float {
        return 1.61803398875
    }
}

struct EffectViewModel {
    let effect: EffectPrototype
    static let viewHeight: CGFloat = 210
    
    func name() -> String {
        switch effect.kind {
        case .reverb: return "reverb"
        case .harmonizer: return "harmonizer"
        case .phaseVocoder: return "phase vocoder"
        case .delay: return "delay"
        case .amp: return "amp"
        case .compressor: return "compressor"
        }
    }
    
    func color() -> NSColor {
        switch effect.kind {
        case .reverb: return NSColor(calibratedRed: 119.0 / 255.0, green: 74.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        case .harmonizer: return NSColor(calibratedRed: 74.0 / 255.0, green: 226.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
        case .phaseVocoder: return NSColor(calibratedRed: 226.0 / 255.0, green: 224.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        case .delay: return NSColor(calibratedRed: 74.0 / 255.0, green: 136.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        case .amp: return NSColor(calibratedRed: 226 / 255.0, green: 74 / 255.0, blue: 74 / 255.0, alpha: 1.0)
        case .compressor: return NSColor("4AE24C")!
        }
    }
}

struct SliderViewModel {
    let sliderWidth: CGFloat = EffectViewModel.viewHeight / CGFloat(Float.goldenRatio)
}

struct EffectsOrderViewModel {
    let rowHeight: CGFloat = 50.0
    let addButtonheight: CGFloat = 45.0
}

struct EffectsFactoryViewModel {
    let tileSize: CGFloat = 130.0
}
