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
    static var waveNodesFactory: WaveNodesFactory!
    
    public static func configureWaveMap(_ waveMap: WaveMap, configuration: [String: Any]) {
        for nodeJsonObject in configuration["nodes"] as! [JsonObject] {
            let waveNode = waveNodeFromJson(nodeJsonObject["model"] as! JsonObject)
            waveMap.addWaveNode(waveNode: waveNode)
            
            let x = nodeJsonObject["x"] as! CGFloat
            let y = nodeJsonObject["y"] as! CGFloat
            waveMap.updatePosition(CGPoint(x: x, y: y), waveNode: waveNode)
        }
        
        for connectionJsonObjects in configuration["connections"] as! [JsonObject] {
            let firstNodeId = connectionJsonObjects["n_1_id"] as! String
            let firstInterfaceId = connectionJsonObjects["i_1_name"] as! String
            let secondNodeId = connectionJsonObjects["n_2_id"] as! String
            let secondInterfaceId = connectionJsonObjects["i_2_name"] as! String
            
            waveMap.map.connect(lhs: waveMap.connectionEndpoint(nodeId: firstNodeId, interfaceName: firstInterfaceId)!,
                                rhs: waveMap.connectionEndpoint(nodeId: secondNodeId, interfaceName: secondInterfaceId)!)
        }
    }
    
    static func waveNodeFromJson(_ json: JsonObject) -> WaveNode {
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
        default: return "" as! WaveNode
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
        let oscilator = waveNodesFactory.makeOscilator(id: json["id"] as! String)
        oscilator.tune = functionVariableFromJson(json["tune"] as! JsonObject)
        let waveGenerator = WaveGenerator(samplingSettings: waveNodesFactory.samplingSettings)
        waveGenerator.waveShape = WaveShape.all()[json["wave_shape"] as! Int]
        oscilator.waveGenerator = waveGenerator
        return oscilator
    }
    
    static func samplerFromJson(_ json: JsonObject) -> Sampler {
        let decoder = JSONDecoder(object: json)
        let sampler = waveNodesFactory.makeSampler(id: json["id"] as! String)
        sampler.sampleFilePath = try! decoder.decode("audio_file_path")
        sampler.volume = functionVariableFromJson(json["volume"] as! JsonObject)
        return sampler
    }
    
    static func functionVariableFromJson(_ json: JsonObject) -> FunctionVariable {
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
                "connections": connectionsJsonArray]
    }
    
    static func waveNodeConfiguration(_ waveNode: WaveNode) -> JsonObject {
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
                "audio_file_path": sampler.sampleFilePath,
                "volume": functionVariableConfiguration(functionVariable: sampler.volume)
            ]
        }
        if let sum = waveNode as? SumWaveNode {
            return [
                "type": "sum",
                "id": sum.id
            ]
        }
        return "" as! JsonObject
    }
    
    static func functionVariableConfiguration(functionVariable: FunctionVariable) -> JsonObject {
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
        return Sampler(sampleFilePath: "/Users/maciejchmielewski/Documents/GuitarDsp/samples/440.wav", samplingSettings: samplingSettings, id: id)
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
}
