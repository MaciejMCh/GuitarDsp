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
            case .channelPlayer(let channelPlayerEffect):
                channelPlayerEffect.channelPlayer.channels = (configuration["channels"] as! [JsonObject]).map{channelFromJson($0)}
            }
        } catch (_) {
            assert(false)
        }
    }
    
    static func channelFromJson(_ json: JsonObject) -> Channel {
        switch json["type"] as! String {
        case "sampler": return samplerFromJson(json)
        case "808":
            let bass808 = effectsFactory.make808()
            bass808.effects = (json["effects"] as! [JsonObject]).map{waveEffectFromJson($0)}
            bass808.oscilators = (json["oscilators"] as! [JsonObject]).map{oscilatorFromJson($0)}
            bass808.samplers = (json["samplers"] as! [JsonObject]).map{samplerFromJson($0)}
            return bass808
        default: return "" as! Channel
        }
    }
    
    static func waveEffectFromJson(_ json: JsonObject) -> WaveEffect {
        let decoder = JSONDecoder(object: json)
        switch try! decoder.decode("type") as String {
        case "amp":
            let amp = AmpWaveEffect()
            amp.gain = functionVariableFromJson(json["gain"] as! JsonObject)
            return amp
        case "wave_shaper":
            let waveShaper = WaveShaper()
            waveShaper.cubicBezier = cubicBezierFromJson(json["bezier"] as! JsonObject)
            waveShaper.mirrorNegatives = try! decoder.decode("mirror_negatives")
            return waveShaper
        default: return "" as! WaveEffect
        }
    }
    
    static func cubicBezierFromJson(_ json: JsonObject) -> CubicBezier {
        let x1: CGFloat = (json["p1"] as! JsonObject)["x"] as! CGFloat
        let y1: CGFloat = (json["p1"] as! JsonObject)["y"] as! CGFloat
        let x2: CGFloat = (json["p2"] as! JsonObject)["x"] as! CGFloat
        let y2: CGFloat = (json["p2"] as! JsonObject)["y"] as! CGFloat
        
        return CubicBezier(p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))
    }
    
    static func oscilatorFromJson(_ json: JsonObject) -> Oscilator {
        let oscilator = Oscilator(samplingSettings: effectsFactory.samplingSettings)
        oscilator.tune = functionVariableFromJson(json["tune"] as! JsonObject)
        oscilator.volume = functionVariableFromJson(json["volume"] as! JsonObject)
        let waveGenerator = WaveGenerator(samplingSettings: effectsFactory.samplingSettings)
        waveGenerator.waveShape = WaveShape.all()[json["wave_shape"] as! Int]
        oscilator.waveGenerator = waveGenerator
        return oscilator
    }
    
    static func samplerFromJson(_ json: JsonObject) -> Sampler {
        let decoder = JSONDecoder(object: json)
        let sampler = effectsFactory.makeSampler()
        sampler.audioFilePath = try! decoder.decode("audio_file_path")
        sampler.volume = functionVariableFromJson(json["volume"] as! JsonObject)
        return sampler
    }
    
    static func functionVariableFromJson(_ json: JsonObject) -> FunctionVariable {
        let decoder = JSONDecoder(object: json)
        switch try! decoder.decode("type") as String {
        case "constant": return try! decoder.decode("value") as Double
        case "envelope":
            let envelope = EnvelopeFunction()
            envelope.delay = try! decoder.decode("delay") as Double
            envelope.attack = try! decoder.decode("attack") as Double
            envelope.hold = try! decoder.decode("hold") as Double
            envelope.decay = try! decoder.decode("decay") as Double
            envelope.sustain = try! decoder.decode("sustain") as Double
            envelope.release = try! decoder.decode("release") as Double
            if let attackBezierJsonObject = json["attack_bezier"] as? JsonObject {
                envelope.attackBezier = cubicBezierFromJson(attackBezierJsonObject)
            } else {
                envelope.attackBezier = nil
            }
            if let decayBezierJsonObject = json["decay_bezier"] as? JsonObject {
                envelope.decayBezier = cubicBezierFromJson(decayBezierJsonObject)
            } else {
                envelope.decayBezier = nil
            }
            if let releaseBezierJsonObject = json["release_bezier"] as? JsonObject {
                envelope.releaseBezier = cubicBezierFromJson(releaseBezierJsonObject)
            } else {
                envelope.releaseBezier = nil
            }
            
            return envelope
        default:
            return "" as! FunctionVariable
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
        case .channelPlayer(let channelPlayerEffect):
            return ["channels": channelPlayerEffect.channelPlayer.channels.map{channelConfiguration(channel: $0)}]
        }
    }
    
    static func channelConfiguration(channel: Channel) -> JsonObject {
        if let sampler = channel as? Sampler {
            return [
                "type": "sampler",
                "audio_file_path": sampler.audioFilePath,
                "volume": functionVariableConfiguration(functionVariable: sampler.volume)
            ]
        }
        if let bass808 = channel as? Bass808 {
            return [
                "type": "808",
                "samplers": bass808.samplers.map{channelConfiguration(channel: $0)},
                "oscilators": bass808.oscilators.map{oscilatorConfiguration($0)},
                "effects": bass808.effects.map{waveEffectConfiguration($0)}
            ]
        }
        
        return "" as! JsonObject
    }
    
    static func waveEffectConfiguration(_ waveEffect: WaveEffect) -> JsonObject {
        if let ampWaveEffect = waveEffect as? AmpWaveEffect {
            return ["type": "amp",
                    "gain": functionVariableConfiguration(functionVariable: ampWaveEffect.gain)
            ]
        }
        if let waveShaperEffect = waveEffect as? WaveShaper {
            return ["type": "wave_shaper",
                    "bezier": cubicBezierConfiguration(waveShaperEffect.cubicBezier),
                    "mirror_negatives": waveShaperEffect.mirrorNegatives]
        }
        return "" as! JsonObject
    }
    
    static func oscilatorConfiguration(_ oscilator: Oscilator) -> JsonObject {
        return ["wave_shape": WaveShape.all().index(of: oscilator.waveGenerator.waveShape)!,
                "tune": functionVariableConfiguration(functionVariable: oscilator.tune),
                "volume": functionVariableConfiguration(functionVariable: oscilator.volume)]
    }
    
    static func functionVariableConfiguration(functionVariable: FunctionVariable) -> JsonObject {
        if let double = functionVariable as? Double {
            return ["type": "constant", "value": double]
        }
        if let envelope = functionVariable as? EnvelopeFunction {
            var result: JsonObject = ["type": "envelope",
                                      "delay": envelope.delay,
                                      "attack": envelope.attack,
                                      "hold": envelope.hold,
                                      "decay": envelope.decay,
                                      "sustain": envelope.sustain,
                                      "release": envelope.release,
                                      "duration": envelope.duration]
            if let attackBezier = envelope.attackBezier {
                result["attack_bezier"] = cubicBezierConfiguration(attackBezier)
            }
            if let decayBezier = envelope.decayBezier {
                result["decay_bezier"] = cubicBezierConfiguration(decayBezier)
            }
            if let releaseBezier = envelope.releaseBezier {
                result["release_bezier"] = cubicBezierConfiguration(releaseBezier)
            }
            return result
        }
        
        return "" as! JsonObject
    }
    
    static func cubicBezierConfiguration(_ cubicBezier: CubicBezier) -> JsonObject {
        return ["p1": ["x": cubicBezier.p1.x,
                       "y": cubicBezier.p1.y],
                "p2": ["x": cubicBezier.p2.x,
                       "y": cubicBezier.p2.y]]
    }
}
