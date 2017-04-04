//
//  StorableModel.swift
//  Bow
//
//  Created by Maciej Chmielewski on 04.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import JSONCodable

extension BoardPrototype: JsonObjectRepresentable {
    static var typeName = "board"
    
    init?(jsonObject: JsonObject) {
        guard let effectsJsonArray = jsonObject["effects"] as? JsonArray else {return nil}
        effectPrototypes = []
        for effectJsonObject in effectsJsonArray {
            if let effectProotype = EffectPrototype(jsonObject: effectJsonObject) {
                effectPrototypes.append(effectProotype)
            }
        }
    }
    
    func json() -> JsonObject {
        return ["effects": effectPrototypes.map{$0.json()}]
    }
}

extension EffectPrototype: JsonObjectRepresentable {
    static var typeName = "effect"
    
    init?(jsonObject: JsonObject) {
        let decoder = JSONDecoder(object: jsonObject)
        do {
            kind = try decoder.decode("kind")
            configuration = jsonObject["configuration"] as! JsonObject
            effect = EffectPrototype.makeEffect(kind: kind)
            EffectPrototype.configure(effect: effect, configuration: configuration)
        } catch(_) {
            return nil
        }
    }
    
    func json() -> JsonObject {
        return ["kind": kind.rawValue, "configuration": configuration]
    }
    
    static func makeEffect(kind: Kind) -> Effect {
        switch kind {
        case .amp: return EffectPrototype.effectsFactory.makeAmp()
        case .delay: return EffectPrototype.effectsFactory.makeDelay()
        case .harmonizer: return EffectPrototype.effectsFactory.makeHarmonizer()
        case .phaseVocoder: return EffectPrototype.effectsFactory.makePhaseVocoder()
        case .reverb: return EffectPrototype.effectsFactory.makeReverb()
        }
    }
    
    static func configure(effect: Effect, configuration: JsonObject) {
        let decoder = JSONDecoder(object: configuration)
        do {
            if let ampEffect = effect as? AmpEffect {
                ampEffect.gain = try decoder.decode("gain")
            } else if let reverb = effect as? ReverbEffect {
                reverb.rev.setroomsize(try decoder.decode("roomsize"))
                reverb.rev.setdamp(try decoder.decode("damp"))
                reverb.rev.setdry(try decoder.decode("dry"))
                reverb.rev.setwet(try decoder.decode("wet"))
                reverb.rev.setwidth(try decoder.decode("width"))
            } else if let harmonizerEffect = effect as? HarmonizerEffect {
                harmonizerEffect.shift = try decoder.decode("shift")
                harmonizerEffect.volume = try decoder.decode("volume")
            } else if let phaseVocoderEffect = effect as? PhaseVocoderEffect {
                phaseVocoderEffect.shift = try decoder.decode("shift")
            } else if let delayEffect = effect as? DelayEffect {
                let tactPart = TactPart(rawValue: configuration["tact_part"] as! UInt)
                delayEffect.updateTact(tactPart!)
                delayEffect.updateEchoesCount(configuration["echoes_count"] as! Int32)
                delayEffect.fadingFunctionA = try decoder.decode("fa")
                delayEffect.fadingFunctionB = try decoder.decode("fb")
            } else {
                assert(false, "\(self)")
            }
        } catch (_) {}
    }
    
    static func configuration(effect: Effect) -> JsonObject {
        if let ampEffect = effect as? AmpEffect {
            return ["gain": ampEffect.gain]
        }
        if let reverbEffect = effect as? ReverbEffect {
            return [
                "roomsize": reverbEffect.rev.getroomsize(),
                "damp": reverbEffect.rev.getdamp(),
                "wet": reverbEffect.rev.getwet(),
                "dry": reverbEffect.rev.getdry(),
                "width": reverbEffect.rev.getwidth()
            ]
        }
        if let harmonizerEffect = effect as? HarmonizerEffect {
            return [
                "shift": harmonizerEffect.shift,
                "volume": harmonizerEffect.volume
            ]
        }
        if let phaseVocoderEffect = effect as? PhaseVocoderEffect {
            return [
                "shift": phaseVocoderEffect.shift
            ]
        }
        if let delayEffect = effect as? DelayEffect {
            return [
                "echoes_count": delayEffect.echoesCount,
                "tact_part": delayEffect.timing.tactPart.rawValue,
                "fa": delayEffect.fadingFunctionA,
                "fb": delayEffect.fadingFunctionB,
            ]
        }
        assert(false, "\(self)")
    }
    
    static func kind(effect: Effect) -> Kind {
        switch effect {
        case is AmpEffect: return .amp
        case is ReverbEffect: return .reverb
        case is HarmonizerEffect: return .harmonizer
        case is PhaseVocoderEffect: return .phaseVocoder
        case is DelayEffect: return .delay
        default: assert(false, "\(self)")
        }
    }
}
