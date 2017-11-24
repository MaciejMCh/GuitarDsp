//
//  WaveMapStorage.swift
//  Pods
//
//  Created by Maciej Chmielewski on 15.11.2017.
//

import Foundation
import JSONCodable
import GuitarDsp

typealias JsonObject = [String: Any]

public struct WaveMapStorage {
    public static var waveNodesFactory: WaveNodesFactory!
    
    public static func configureWaveMap(_ waveMap: WaveMap, configuration: [String: Any]) {
        
        let outputX = configuration["out_x"] as? CGFloat ?? 0
        let outputY = configuration["out_y"] as? CGFloat ?? 0
        
        waveMap.outputNode.sprite.position = CGPoint(x: outputX, y: outputY)
        
        for nodeJsonObject in configuration["nodes"] as? [JsonObject] ?? [] {
            let waveNode = waveNodeFromJson(nodeJsonObject["model"] as! JsonObject)
            waveMap.addWaveNode(waveNode: waveNode)
            
            let x = nodeJsonObject["x"] as! CGFloat
            let y = nodeJsonObject["y"] as! CGFloat
            waveMap.updatePosition(CGPoint(x: x, y: y), waveNode: waveNode)
        }
        
        for connectionJsonObjects in configuration["connections"] as? [JsonObject] ?? [] {
            let firstNodeId = connectionJsonObjects["n_1_id"] as! String
            let firstInterfaceId = connectionJsonObjects["i_1_name"] as! String
            let secondNodeId = connectionJsonObjects["n_2_id"] as! String
            let secondInterfaceId = connectionJsonObjects["i_2_name"] as! String
            
            waveMap.map.connect(lhs: waveMap.connectionEndpoint(nodeId: firstNodeId, interfaceName: firstInterfaceId)!,
                                rhs: waveMap.connectionEndpoint(nodeId: secondNodeId, interfaceName: secondInterfaceId)!)
        }
    }
    
    private static func waveNodeFromJson(_ json: JsonObject) -> WaveNode {
        let decoder = JSONDecoder(object: json)
        switch try! decoder.decode("type") as String {
        case "amp":
            let amp = waveNodesFactory.makeAmpWaveEffect(id: json["id"] as! String)
            amp.gain = functionVariableFromJson(json["gain"] as! JsonObject)
            return amp
        case "wave_shaper":
            let waveShaper = waveNodesFactory.makeWaveShaper(id: json["id"] as! String)
            waveShaper.cubicBezier = cubicBezierFromJson(json["bezier"] as! JsonObject)
            waveShaper.mirrorNegatives = try! decoder.decode("mirror_negatives")
            return waveShaper
        case "oscilator":
            return oscilatorFromJson(json)
        case "constant", "envelope": return functionVariableFromJson(json)
        case "sampler": return samplerFromJson(json)
        case "sum": return waveNodesFactory.makeSum(id: json["id"] as! String)
        case "foldback": return waveNodesFactory.makeFoldback(id: json["id"] as! String)
        case "overdrive": return waveNodesFactory.makeOverdrive(id: json["id"] as! String)
        case "lpf": return waveNodesFactory.makeLpf(id: json["id"] as! String)
        case "saturation": return waveNodesFactory.makeSaturation(id: json["id"] as! String)
        case "reverb": return reverbFromJson(json)
        case "phaser": return phaserFromJson(json)
        default:
            debugPrint(json)
            return "" as! WaveNode
        }
    }
    
    private static func reverbFromJson(_ json: JsonObject) -> ReverbWaveEffect {
        let reverb = waveNodesFactory.makeReverb(id: json["id"] as! String)
        reverb.freeverb.setdamp(json["damp"] as! Float)
        reverb.freeverb.setroomsize(json["room_size"] as! Float)
        return reverb
    }
    
    private static func phaserFromJson(_ json: JsonObject) -> PhaserWaveEffect {
        let phaser = waveNodesFactory.makePhaser(id: json["id"] as! String)
        phaser.phaserEffect.updateRangeFmin(json["f_min"] as! Float, fMax: json["f_max"] as! Float)
        phaser.phaserEffect.updateRate(json["rate"] as! Float)
        phaser.phaserEffect.updateDepth(json["depth"] as! Float)
        phaser.phaserEffect.updateFeedback(json["feedback"] as! Float)
        return phaser
    }
    
    private static func cubicBezierFromJson(_ json: JsonObject) -> CubicBezier {
        let x1: CGFloat = (json["p1"] as! JsonObject)["x"] as! CGFloat
        let y1: CGFloat = (json["p1"] as! JsonObject)["y"] as! CGFloat
        let x2: CGFloat = (json["p2"] as! JsonObject)["x"] as! CGFloat
        let y2: CGFloat = (json["p2"] as! JsonObject)["y"] as! CGFloat
        
        return CubicBezier(p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))
    }
    
    private static func oscilatorFromJson(_ json: JsonObject) -> Oscilator {
        let oscilator = waveNodesFactory.makeOscilator(id: json["id"] as! String)
        oscilator.tune = functionVariableFromJson(json["tune"] as! JsonObject)
        let waveGenerator = WaveGenerator(samplingSettings: waveNodesFactory.samplingSettings)
        waveGenerator.waveShape = WaveShape.all()[json["wave_shape"] as! Int]
        oscilator.waveGenerator = waveGenerator
        return oscilator
    }
    
    private static func samplerFromJson(_ json: JsonObject) -> Sampler {
        let decoder = JSONDecoder(object: json)
        let sampler = waveNodesFactory.makeSampler(id: json["id"] as! String)
        let audioFilePath: String = try! decoder.decode("audio_file_path")
        sampler.sampleFilePath = "\(StorageConstants.samplesRootDirectory)/\(audioFilePath)"
        sampler.volume = functionVariableFromJson(json["volume"] as! JsonObject)
        return sampler
    }
    
    private static func functionVariableFromJson(_ json: JsonObject) -> FunctionVariable {
        let decoder = JSONDecoder(object: json)
        switch try! decoder.decode("type") as String {
        case "constant":
            let constant = waveNodesFactory.makeConstant(id: json["id"] as! String)
            constant.value = try! decoder.decode("value")
            return constant
        case "envelope":
            let envelope = waveNodesFactory.makeEnvelope(id: json["id"] as! String)
            envelope.delay = try! decoder.decode("delay") as Double
            envelope.attack = try! decoder.decode("attack") as Double
            envelope.hold = try! decoder.decode("hold") as Double
            envelope.decay = try! decoder.decode("decay") as Double
            envelope.sustain = try! decoder.decode("sustain") as Double
            envelope.release = try! decoder.decode("release") as Double
            envelope.volume = try! decoder.decode("volume") as Double
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
    
    public static func waveMapConfiguration(_ waveMap: WaveMap) -> [String: Any] {
        var waveNodesJsonArray: [JsonObject] = []
        for waveNode in waveMap.waveNodes {
            let modelConfiguration = waveNodeConfiguration(waveNode)
            let position = waveMap.position(waveNode: waveNode)!
            waveNodesJsonArray.append([
                "model": modelConfiguration,
                "x": position.x,
                "y": position.y
                ])
        }
        
        var connectionsJsonArray: [JsonObject] = []
        for connection in waveMap.map.connections {
            connectionsJsonArray.append([
                "n_1_id": connection.0.0.model.id,
                "i_1_name": connection.0.1.name,
                "n_2_id": connection.1.0.model.id,
                "i_2_name": connection.1.1.name
                ])
        }
        
        return ["nodes": waveNodesJsonArray,
                "connections": connectionsJsonArray,
                "out_x": waveMap.outputNode.sprite.position.x,
                "out_y": waveMap.outputNode.sprite.position.y
        ]
    }
    
    private static func waveNodeConfiguration(_ waveNode: WaveNode) -> JsonObject {
        if let ampWaveEffect = waveNode as? AmpWaveEffect {
            return ["type": "amp",
                    "id": ampWaveEffect.id,
                    "gain": functionVariableConfiguration(functionVariable: ampWaveEffect.gain)
            ]
        }
        if let waveShaperEffect = waveNode as? WaveShaper {
            return ["type": "wave_shaper",
                    "id": waveShaperEffect.id,
                    "bezier": cubicBezierConfiguration(waveShaperEffect.cubicBezier),
                    "mirror_negatives": waveShaperEffect.mirrorNegatives]
        }
        if let oscilator = waveNode as? Oscilator {
            return ["type": "oscilator",
                    "id": oscilator.id,
                    "wave_shape": WaveShape.all().index(of: oscilator.waveGenerator.waveShape)!,
                    "tune": functionVariableConfiguration(functionVariable: oscilator.tune)]
        }
        if let functionVariable = waveNode as? FunctionVariable {
            return functionVariableConfiguration(functionVariable: functionVariable)
        }
        if let sampler = waveNode as? Sampler {
            return [
                "type": "sampler",
                "id": sampler.id,
                "audio_file_path": sampler.sampleFilePath.components(separatedBy: "samples/").last!,
                "volume": functionVariableConfiguration(functionVariable: sampler.volume)
            ]
        }
        if let sum = waveNode as? SumWaveNode {
            return [
                "type": "sum",
                "id": sum.id
            ]
        }
        if let foldBack = waveNode as? FoldbackWaveEffect {
            return [
                "type": "foldback",
                "id": foldBack.id
            ]
        }
        if let overdrive = waveNode as? OverdriveWaveEffect {
            return [
                "type": "overdrive",
                "id": overdrive.id
            ]
        }
        if let lpf = waveNode as? LowpassFilterEffect {
            return [
                "type": "lpf",
                "id": lpf.id
            ]
        }
        if let saturation = waveNode as? SaturationWaveEffect {
            return [
                "type": "saturation",
                "id": saturation.id
            ]
        }
        if let reverb = waveNode as? ReverbWaveEffect {
            return [
                "type": "reverb",
                "id": reverb.id,
                "room_size": reverb.freeverb.getroomsize(),
                "damp": reverb.freeverb.getdamp()
            ]
        }
        if let phaser = waveNode as? PhaserWaveEffect {
            return [
                "type": "phaser",
                "id": phaser.id,
                "depth": phaser.phaserEffect.depth,
                "feedback": phaser.phaserEffect.feedback,
                "rate": phaser.phaserEffect.rate,
                "f_max": phaser.phaserEffect.rangeFmax,
                "f_min": phaser.phaserEffect.rangeFmin
            ]
        }
        return "" as! JsonObject
    }
    
    private static func functionVariableConfiguration(functionVariable: FunctionVariable) -> JsonObject {
        if let constant = functionVariable as? Constant {
            return ["type": "constant",
                    "id": constant.id,
                    "value": constant.value]
        }
        if let envelope = functionVariable as? EnvelopeFunction {
            var result: JsonObject = ["type": "envelope",
                                      "id": envelope.id,
                                      "delay": envelope.delay,
                                      "attack": envelope.attack,
                                      "hold": envelope.hold,
                                      "decay": envelope.decay,
                                      "sustain": envelope.sustain,
                                      "release": envelope.release,
                                      "duration": envelope.duration,
                                      "volume": envelope.volume]
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

public struct WaveNodesFactory {
    let samplingSettings: SamplingSettings
    
    public init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
    }
    
    func makeSampler(id: String? = nil) -> Sampler {
        return Sampler(sampleFilePath: Bundle.main.path(forResource: "440", ofType: "wav")!, samplingSettings: samplingSettings, id: id)
    }
    
    func makeOscilator(id: String? = nil) -> Oscilator {
        return Oscilator(samplingSettings: samplingSettings, id: id)
    }
    
    func makeEnvelope(id: String? = nil) -> EnvelopeFunction {
        return EnvelopeFunction(id: id)
    }
    
    func makeConstant(id: String? = nil) -> Constant {
        return Constant(value: 1, id: id)
    }
    
    func makeAmpWaveEffect(id: String? = nil) -> AmpWaveEffect {
        return AmpWaveEffect(id: id)
    }
    
    func makeWaveShaper(id: String? = nil) -> WaveShaper {
        return WaveShaper(id: id)
    }
    
    func makeFoldback(id: String? = nil) -> FoldbackWaveEffect {
        return FoldbackWaveEffect(id: id)
    }
    
    func makeSum(id: String? = nil) -> SumWaveNode {
        return SumWaveNode(id: id)
    }
    
    func makeOverdrive(id: String? = nil) -> OverdriveWaveEffect {
        return OverdriveWaveEffect(id: id)
    }
    
    func makeLpf(id: String? = nil) -> LowpassFilterEffect {
        return LowpassFilterEffect(id: id)
    }
    
    func makeSaturation(id: String? = nil) -> SaturationWaveEffect {
        return SaturationWaveEffect(id: id)
    }
    
    func makeReverb(id: String? = nil) -> ReverbWaveEffect {
        return ReverbWaveEffect(id: id)
    }
    
    func makePhaser(id: String? = nil) -> PhaserWaveEffect {
        return PhaserWaveEffect(samplingSettings: samplingSettings, id: id)
    }
}

extension WaveMap {
    static func fromPath(_ path: String, midiOutput: MidiOutput?) -> WaveMap {
        let waveMap = WaveMap(samplingSettings: AudioInterface.shared().samplingSettings, midiOutput: midiOutput)
        let configuration = NSKeyedUnarchiver.unarchiveObject(withFile: StorageConstants.waveMapsRootDirectory + "/" + path) as! [String: Any]
        WaveMapStorage.configureWaveMap(waveMap, configuration: configuration)
        return waveMap
    }
}
