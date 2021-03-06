//
//  WaveMap.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 23.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import NodesMap
import GuitarDsp

extension String: Indentificable {
    public var id: String {return self}
}

public class WaveMap: NSObject, Effect, MidiPlayer {
    let samplingSettings: SamplingSettings
    public lazy var map: Map = {
        Map.wave(waveMap: self)
    }()
    public var waveNodes: [WaveNode] = []
    public let output = SignalInput()
    public let outputNode: Node
    var midiOutput: MidiOutput
    private var time = 0
    
    public init(samplingSettings: SamplingSettings, midiOutput: MidiOutput) {
        self.samplingSettings = samplingSettings
        self.midiOutput = midiOutput
        outputNode = Node(name: "output", interfaces: [Interface(name: "in", model: output)], model: "none")
        super.init()
        map.addNode(outputNode)
    }
    
    public func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        var buffer: [Float] = Array(repeating: 0, count: Int(samplingSettings.framesPerPacket))
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            buffer[i] = inputSample.amp.advanced(by: i).pointee
        }
        
        for event in midiOutput.detectEvents(buffer: buffer) {
            switch event {
            case .on: on()
            case .off: off()
            case .frequency(let frequency): setFrequency(frequency)
            }
        }
        
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            defer {
                time += 1
            }
            if let sampleFromOutput = output.output?.next(time) {
                outputBuffer.advanced(by: i).pointee = Float(sampleFromOutput)
            } else {
                outputBuffer.advanced(by: i).pointee = 0
            }
        }
    }
    
    public func connectionEndpoint(nodeId: String, interfaceName: String) -> ConnectionEndpoint? {
        guard let node = node(id: nodeId) else {return nil}
        for interface in node.interfaces {
            if interface.name == interfaceName {
                return (node, interface)
            }
        }
        return nil
    }
    
    func node(id: String) -> Node? {
        for node in map.nodes {
            if node.model.id == id {
                return node
            }
        }
        return nil
    }
    
    public func startAddingWaveNode(_ waveNode: WaveNode) {
        waveNodes.append(waveNode)
        map.startAddingNode(nodeFromWaveNode(waveNode))
    }
    
    public func addWaveNode(waveNode: WaveNode) {
        waveNodes.append(waveNode)
        map.addNode(nodeFromWaveNode(waveNode))
    }
    
    public func position(waveNode: WaveNode) -> CGPoint? {
        for spriteNode in map.nodes {
            if spriteNode.model.id == waveNode.id {
                return spriteNode.sprite.position
            }
        }
        return nil
    }
    
    public func updatePosition(_ position: CGPoint, waveNode: WaveNode) {
        for spriteNode in map.nodes {
            if spriteNode.model.id == waveNode.id {
                spriteNode.sprite.position = position
            }
        }
    }
    
    public func on() {
        for waveNode in waveNodes {
            waveNode.on()
        }
    }
    
    public func off() {
        for waveNode in waveNodes {
            waveNode.off()
        }
    }
    
    public func setFrequency(_ frequency: Double) {
        for waveNode in waveNodes {
            waveNode.setFrequency(frequency)
        }
    }
    
    private func nodeFromWaveNode(_ waveNode: WaveNode) -> Node {
        if let envelope = waveNode as? EnvelopeFunction {
            return WaveMap.nodeFromEnvelope(envelope)
        }
        if let oscilator = waveNode as? Oscilator {
            return WaveMap.nodeFromOscilator(oscilator)
        }
        if let amp = waveNode as? AmpWaveEffect {
            return WaveMap.nodeFromAmp(amp)
        }
        if let constant = waveNode as? Constant {
            return WaveMap.nodeFromConstant(constant)
        }
        if let sampler = waveNode as? Sampler {
            return WaveMap.nodeFromSampler(sampler)
        }
        if let sum = waveNode as? SumWaveNode {
            return WaveMap.nodeFromSum(sum)
        }
        if let waveShaper = waveNode as? WaveShaper {
            return WaveMap.nodeFromWaveShaper(waveShaper)
        }
        if let overdrive = waveNode as? OverdriveWaveEffect {
            return WaveMap.nodeFromOverdrive(overdrive)
        }
        if let foldback = waveNode as? FoldbackWaveEffect {
            return WaveMap.nodeFromFoldback(foldback)
        }
        if let lpf = waveNode as? LowpassFilterEffect {
            return WaveMap.nodeFromLpf(lpf)
        }
        if let saturation = waveNode as? SaturationWaveEffect {
            return WaveMap.nodeFromSaturation(saturation)
        }
        
        return "" as! Node
    }
    
    fileprivate static func nodeFromEnvelope(_ envelope: EnvelopeFunction) -> Node {
        return Node(name: "envelope",
                    interfaces: [Interface(name: "out", model: envelope)],
                    model: envelope)
    }
    
    fileprivate static func nodeFromOscilator(_ oscilator: Oscilator) -> Node {
        return Node(name: "oscilator",
                    interfaces: [Interface(name: "out", model: oscilator.output),
                                 Interface(name: "tune", model: oscilator.tuneSetter)],
                    model: oscilator)
    }
    
    fileprivate static func nodeFromAmp(_ amp: AmpWaveEffect) -> Node {
        return Node(name: "amp",
                    interfaces: [Interface(name: "in", model: amp.input),
                                 Interface(name: "out", model: amp.output),
                                 Interface(name: "gain", model: amp.gainSetter)],
                    model: amp)
    }
    
    fileprivate static func nodeFromConstant(_ constant: Constant) -> Node {
        return Node(name: "constant",
                    interfaces: [Interface(name: "out", model: constant)],
                    model: constant)
    }
    
    fileprivate static func nodeFromSampler(_ sampler: Sampler) -> Node {
        return Node(name: "sampler",
                    interfaces: [Interface(name: "out", model: sampler.output)],
                    model: sampler)
    }
    
    fileprivate static func nodeFromSum(_ sum: SumWaveNode) -> Node {
        return Node(name: "sum",
                    interfaces: [
                        Interface(name: "in", model: sum.inputCollection),
                        Interface(name: "out", model: sum.output)],
                    model: sum)
    }
    
    fileprivate static func nodeFromWaveShaper(_ waveShaper: WaveShaper) -> Node {
        return Node(name: "wave shaper",
                    interfaces: [
                        Interface(name: "in", model: waveShaper.input),
                        Interface(name: "out", model: waveShaper.output)],
                    model: waveShaper)
    }
    fileprivate static func nodeFromOverdrive(_ overdrve: OverdriveWaveEffect) -> Node {
        return Node(name: "overdrive",
                    interfaces: [
                        Interface(name: "in", model: overdrve.input),
                        Interface(name: "out", model: overdrve.output),
                        Interface(name: "treshold", model: overdrve.tresholdSetter)],
                    model: overdrve)
    }
    fileprivate static func nodeFromFoldback(_ foldback: FoldbackWaveEffect) -> Node {
        return Node(name: "foldback",
                    interfaces: [
                        Interface(name: "in", model: foldback.input),
                        Interface(name: "out", model: foldback.output),
                        Interface(name: "treshold", model: foldback.tresholdSetter)],
                    model: foldback)
    }
    fileprivate static func nodeFromLpf(_ lpf: LowpassFilterEffect) -> Node {
        return Node(name: "lpf",
                    interfaces: [
                        Interface(name: "in", model: lpf.input),
                        Interface(name: "out", model: lpf.output),
                        Interface(name: "width", model: lpf.widthSetter)],
                    model: lpf)
    }
    fileprivate static func nodeFromSaturation(_ saturation: SaturationWaveEffect) -> Node {
        return Node(name: "saturation",
                    interfaces: [
                        Interface(name: "in", model: saturation.input),
                        Interface(name: "out", model: saturation.output),
                        Interface(name: "level", model: saturation.levelSetter)],
                    model: saturation)
    }
}

extension SaturationWaveEffect {
    var levelSetter: FunctionVariableSetter {return {self.level = $0}}
}

extension LowpassFilterEffect {
    var widthSetter: FunctionVariableSetter {return {self.width = $0}}
}

extension FoldbackWaveEffect {
    var tresholdSetter: FunctionVariableSetter {return {self.treshold = $0}}
}

extension Oscilator {
    var tuneSetter: FunctionVariableSetter {return {self.tune = $0}}
}

extension AmpWaveEffect {
    var gainSetter: FunctionVariableSetter {return {self.gain = $0}}
}

extension OverdriveWaveEffect {
    var tresholdSetter: FunctionVariableSetter {return {self.treshold = $0}}
}

extension Map {
    static func wave(waveMap: WaveMap) -> Map {
        let map = Map(connect: { (lhs, rhs) in
            
            if (with(lhs: lhs.1.model, rhs: rhs.1.model) { (input: SignalInput, output: SignalOutput) in
                input.output = output
            }) {return true}
            
            if (with(lhs: lhs.1.model, rhs: rhs.1.model) { (variable: FunctionVariable, variableSetter: FunctionVariableSetter) in
                variableSetter(variable)
            }) {return true}
            
            if (with(lhs: lhs.1.model, rhs: rhs.1.model) { (output: SignalOutput, inputsCollection: SumWaveNode.InputsCollection) in
                inputsCollection.outputs.append(output)
            }) {return true}
            
            return false
        }, breakConnection: { (lhs, rhs) in
            if (oneOf(lhs: lhs.1.model, rhs: rhs.1.model) { (input: SignalInput) in
                input.output = nil
            }) {return true}
            
            if (oneOf(lhs: lhs.1.model, rhs: rhs.1.model) { (variableSetter: FunctionVariableSetter) in
                variableSetter(Constant(value: 0))
            }) {return true}
            
            if (with(lhs: lhs.1.model, rhs: rhs.1.model) { (output: SignalOutput, inputsCollection: SumWaveNode.InputsCollection) in
                inputsCollection.outputs = inputsCollection.outputs.filter{$0 != output}
            }) {return true}
            
            return false
        }, remove: {[weak waveMap] node in
            guard let waveMap = waveMap else {return false}
            var nodeIndexToRemove: Int?
            var i = 0
            for waveNode in waveMap.waveNodes {
                defer {
                    i += 1
                }
                if waveNode.id == node.model.id {
                    nodeIndexToRemove = i
                }
            }
            
            if let nodeIndexToRemove = nodeIndexToRemove {
                waveMap.waveNodes.remove(at: nodeIndexToRemove)
                return true
            } else {
                return false
            }
        })
        return map
    }
    
    static func with<T, U>(lhs: Any, rhs: Any, operation: (T, U) -> Void) -> Bool {
        let t = [lhs, rhs].flatMap{$0 as? T}.first
        let u = [lhs, rhs].flatMap{$0 as? U}.first
        
        if let t = t, let u = u {
            operation(t, u)
            return true
        }
        
        return false
    }
    
    static func oneOf<T>(lhs: Any, rhs: Any, operation: (T) -> Void) -> Bool {
        var result = false
        if let tLhs = lhs as? T {
            operation(tLhs)
            result = result || true
        }
        if let tRhs = rhs as? T {
            operation(tRhs)
            result = result || true
        }
        return result
    }
}
