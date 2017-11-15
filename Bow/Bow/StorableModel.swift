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
import GuitarMidi

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
            let kind: String = try decoder.decode("kind")
            instance = Instance(kind: kind, effectFactory: EffectPrototype.effectsFactory)
            configuration = jsonObject["configuration"] as! JsonObject
        } catch(_) {
            return nil
        }
    }
    
    func json() -> JsonObject {
        return ["kind": instance.kind, "configuration": configuration]
    }
    
    static func configure(effect: EffectPrototype.Instance, configuration: JsonObject) {
        let decoder = JSONDecoder(object: configuration)
        do {
            switch effect {
            case .amp(let ampEffect):
                ampEffect.gain = try decoder.decode("gain")
            case .bitCrusher(let bitCrusherEffect):
                bitCrusherEffect.samplingReduction = try decoder.decode("sampling_reduction")
                bitCrusherEffect.dry = try decoder.decode("dry")
                bitCrusherEffect.wet = try decoder.decode("wet")
            case .compressor(let compressorEffect):
                compressorEffect.fadingLevel = try decoder.decode("fading_level")
                compressorEffect.noiseLevel = try decoder.decode("noise_level")
            case .delay(let delayEffect):
                let tactPart = TactPart(rawValue: configuration["tact_part"] as! UInt)
                delayEffect.updateTact(tactPart!)
                delayEffect.updateEchoesCount(configuration["echoes_count"] as! Int32)
                delayEffect.fadingFunctionA = try decoder.decode("fa")
                delayEffect.fadingFunctionB = try decoder.decode("fb")
            case .flanger(let flangerEffect):
                flangerEffect.frequency = try decoder.decode("frequency")
                flangerEffect.depth = try decoder.decode("depth")
            case .harmonizer(let harmonizerEffect):
                harmonizerEffect.shift = try decoder.decode("shift")
                harmonizerEffect.volume = try decoder.decode("volume")
            case .phaseVocoder(let phaseVocoderEffect):
                phaseVocoderEffect.shift = try decoder.decode("shift")
            case .reverb(let reverbEffect):
                reverbEffect.rev.setroomsize(try decoder.decode("roomsize"))
                reverbEffect.rev.setdamp(try decoder.decode("damp"))
                reverbEffect.rev.setdry(try decoder.decode("dry"))
                reverbEffect.rev.setwet(try decoder.decode("wet"))
                reverbEffect.rev.setwidth(try decoder.decode("width"))
            case .vibe(let vibeEffect):
                vibeEffect.frequency = try decoder.decode("frequency")
                vibeEffect.depth = try decoder.decode("depth")
            case .phaser(let phaserEffect): break
//                phaserEffect.rate = try decoder.decode("rate")
//                phaserEffect.fMax = try decoder.decode("f_max")
//                phaserEffect.fMin = try decoder.decode("f_min")
            case .distortion(let distortionEffect):
                distortionEffect.level = try decoder.decode("level")
                distortionEffect.treshold = try decoder.decode("treshold")
            case .waveMap(let waveMap):
                WaveMapStorage.configureWaveMap(waveMap, configuration: configuration)
            }
        } catch (_) {
            assert(false)
        }
    }
    
    static func configuration(effect: EffectPrototype.Instance) -> JsonObject {
        switch effect {
        case .amp(let ampEffect):
            return ["gain": ampEffect.gain]
        case .bitCrusher(let bitCrusherEffect):
            return [
                "sampling_reduction": bitCrusherEffect.samplingReduction,
                "dry": bitCrusherEffect.dry,
                "wet": bitCrusherEffect.wet
            ]
        case .compressor(let compressorEffect):
            return [
                "fading_level": compressorEffect.fadingLevel,
                "noise_level": compressorEffect.noiseLevel
            ]
        case .delay(let delayEffect):
            return [
                "echoes_count": delayEffect.echoesCount,
                "tact_part": delayEffect.timing.tactPart.rawValue,
                "fa": delayEffect.fadingFunctionA,
                "fb": delayEffect.fadingFunctionB,
            ]
        case .flanger(let flangerEffect):
            return [
                "frequency": flangerEffect.frequency,
                "depth": flangerEffect.depth
            ]
        case .harmonizer(let harmonizerEffect):
            return [
                "shift": harmonizerEffect.shift,
                "volume": harmonizerEffect.volume
            ]
        case .phaseVocoder(let phaseVocoderEffect):
            return [
                "shift": phaseVocoderEffect.shift
            ]
        case .reverb(let reverbEffect):
            return [
                "roomsize": reverbEffect.rev.getroomsize(),
                "damp": reverbEffect.rev.getdamp(),
                "wet": reverbEffect.rev.getwet(),
                "dry": reverbEffect.rev.getdry(),
                "width": reverbEffect.rev.getwidth()
            ]
        case .vibe(let vibeEffect):
            return [
                "frequency": vibeEffect.frequency,
                "depth": vibeEffect.depth
            ]
        case .phaser(let phaserEffect):
            return [:
//                "rate": phaserEffect.rate,
//                "f_max": phaserEffect.fMax,
//                "f_min": phaserEffect.fMin
            ]
        case .distortion(let distortionEffect):
            return [
                "level": distortionEffect.level,
                "treshold": distortionEffect.treshold
            ]
        case .waveMap(let waveMap):
            return WaveMapStorage.waveMapConfiguration(waveMap)
        }
    }
}
