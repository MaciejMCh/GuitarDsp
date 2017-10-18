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
    let effect: EffectPrototype.Instance
    static let viewHeight: CGFloat = 210
    
    func name() -> String {
        switch effect {
        case .reverb: return "reverb"
        case .harmonizer: return "harmonizer"
        case .phaseVocoder: return "phase vocoder"
        case .delay: return "delay"
        case .amp: return "amp"
        case .compressor: return "compressor"
        case .bitCrusher: return "bit crusher"
        case .vibe: return "vibe"
        case .flanger: return "flanger"
        case .phaser: return "phaser"
        case .distortion: return "distortion"
        case .waveMap: return "wave map"
        }
    }
    
    func color() -> NSColor {
        switch effect {
        case .reverb: return NSColor(calibratedRed: 119.0 / 255.0, green: 74.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        case .harmonizer: return NSColor(calibratedRed: 74.0 / 255.0, green: 226.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
        case .phaseVocoder: return NSColor(calibratedRed: 226.0 / 255.0, green: 224.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        case .delay: return NSColor(calibratedRed: 74.0 / 255.0, green: 136.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        case .amp: return NSColor(calibratedRed: 226 / 255.0, green: 74 / 255.0, blue: 74 / 255.0, alpha: 1.0)
        case .compressor: return NSColor("4AE24C")!
        case .bitCrusher: return NSColor("BFE24A")!
        case .vibe: return NSColor("E24ACE")!
        case .flanger: return NSColor("4AD0E2")!
        case .phaser: return NSColor("4AE2B4")!
        case .distortion: return NSColor("E24A4A")!
        case .waveMap: return .black
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
