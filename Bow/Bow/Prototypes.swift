//
//  Prototypes.swift
//  Bow
//
//  Created by Maciej Chmielewski on 04.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import GuitarMidi

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
        board.effects = effectPrototypes.map{$0.instance.effect}
        return board
    }
}

extension EffectPrototype {
    enum Instance {
        case reverb(ReverbEffect)
        case harmonizer(HarmonizerEffect)
        case phaseVocoder(PhaseVocoderEffect)
        case delay(DelayEffect)
        case amp(AmpEffect)
        case compressor(CompressorEffect)
        case bitCrusher(BitCrusherEffect)
        case vibe(VibeEffect)
        case flanger(FlangerEffect)
        case phaser(PhaserEffect)
        case distortion(DistortionEffect)
        case waveMap(WaveMap)
    }
}

extension EffectPrototype.Instance {
    typealias Kind = String
    
    // Kind mapping
    init!(kind: Kind, effectFactory: EffectsFacory) {
        switch kind {
        case "amp": self = .amp(effectFactory.makeAmp())
        case "bit_crusher": self = .bitCrusher(effectFactory.makeBitCrusher())
        case "compressor": self = .compressor(effectFactory.makeCompressor())
        case "delay": self = .delay(effectFactory.makeDelay())
        case "harmonizer": self = .harmonizer(effectFactory.makeHarmonizer())
        case "phase_vocoder": self = .phaseVocoder(effectFactory.makePhaseVocoder())
        case "reverb": self = .reverb(effectFactory.makeReverb())
        case "vibe": self = .vibe(effectFactory.makeVibe())
        case "flanger": self = .flanger(effectFactory.makeFlanger())
        case "distortion": self = .distortion(effectFactory.makeDistortion())
        case "wave_map": self = .waveMap(effectFactory.makeWaveMap())
        default:
            assert(false)
            return nil
        }
    }
    
    var kind: Kind {
        switch self {
        case .amp: return "amp"
        case .bitCrusher: return "bit_crusher"
        case .compressor: return "compressor"
        case .delay: return "delay"
        case .harmonizer: return "harmonizer"
        case .phaseVocoder: return "phase_vocoder"
        case .reverb: return "reverb"
        case .vibe: return "vibe"
        case .flanger: return "flanger"
        case .phaser: return "phaser"
        case .distortion: return "distortion"
        case .waveMap: return "wave_map"
        }
    }
    
    // Effect mapping
    init!(effect: Effect) {
        if let ampEffect = effect as? AmpEffect {
            self = .amp(ampEffect)
        } else if let bitCrusherEffect = effect as? BitCrusherEffect {
            self = .bitCrusher(bitCrusherEffect)
        } else if let compressorEffect = effect as? CompressorEffect {
            self = .compressor(compressorEffect)
        } else if let delayEffect = effect as? DelayEffect {
            self = .delay(delayEffect)
        } else if let harmonizerEffect = effect as? HarmonizerEffect {
            self = .harmonizer(harmonizerEffect)
        } else if let phaseVocoderEffect = effect as? PhaseVocoderEffect {
            self = .phaseVocoder(phaseVocoderEffect)
        } else if let reverbEffect = effect as? ReverbEffect {
            self = .reverb(reverbEffect)
        } else if let vibeEffect = effect as? VibeEffect {
            self = .vibe(vibeEffect)
        } else if let flangerEffect = effect as? FlangerEffect {
            self = .flanger(flangerEffect)
        } else if let phaserEffect = effect as? PhaserEffect {
            self = .phaser(phaserEffect)
        } else if let distortionEffect = effect as? DistortionEffect {
            self = .distortion(distortionEffect)
        } else if let waveMap = effect as? WaveMap {
            self = .waveMap(waveMap)
        } else {
            assert(false)
            return nil
        }
    }
    
    var effect: Effect {
        switch self {
        case .amp(let effect): return effect
        case .bitCrusher(let effect): return effect
        case .compressor(let effect): return effect
        case .delay(let effect): return effect
        case .harmonizer(let effect): return effect
        case .phaseVocoder(let effect): return effect
        case .reverb(let effect): return effect
        case .vibe(let effect): return effect
        case .flanger(let effect): return effect
        case .phaser(let effect): return effect
        case .distortion(let effect): return effect
        case .waveMap(let effect): return effect
        }
    }
}

struct EffectPrototype {
    static var effectsFactory: EffectsFacory!
    let instance: Instance
    
    var configuration: JsonObject {
        get {
            return EffectPrototype.configuration(effect: instance)
        }
        set {
            EffectPrototype.configure(effect: instance, configuration: newValue)
        }
    }
    
    init(effect: Effect) {
        instance = Instance(effect: effect)
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
