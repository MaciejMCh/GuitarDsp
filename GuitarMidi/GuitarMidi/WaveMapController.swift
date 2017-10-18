//
//  WaveMapController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 06.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import NodesMap
import GuitarDsp

extension String: Indentificable {
    public var id: String {return self}
}

public class WaveMap: NSObject, Effect, MidiPlayer {
    let samplingSettings: SamplingSettings
    public let map = Map.wave()
    public var waveNodes: [WaveNode] = []
    public let output = SignalInput()
    private var time = 0
    private let midiOutput: MidiOutput
    
    public init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        midiOutput = MidiOutput(samplingSettings: samplingSettings)
        super.init()
        map.addNode(Node(name: "output", interfaces: [Interface(name: "in", model: self)], model: "none"))
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
    
    public func addWaveNode(waveNode: WaveNode) {
        waveNodes.append(waveNode)
        
        if let envelope = waveNode as? EnvelopeFunction {
            map.addNode(WaveMap.nodeFromEnvelope(envelope))
            return
        }
        if let oscilator = waveNode as? Oscilator {
            map.addNode(WaveMap.nodeFromOscilator(oscilator))
            return
        }
        if let amp = waveNode as? AmpWaveEffect {
            map.addNode(WaveMap.nodeFromAmp(amp))
            return
        }
        if let constant = waveNode as? Constant {
            map.addNode(WaveMap.nodeFromConstant(constant))
            return
        }
        if let sampler = waveNode as? Sampler {
            map.addNode(WaveMap.nodeFromSampler(sampler))
            return
        }
        if let sum = waveNode as? SumWaveNode {
            map.addNode(WaveMap.nodeFromSum(sum))
            return
        }
        if let waveShaper = waveNode as? WaveShaper {
            map.addNode(WaveMap.nodeFromWaveShaper(waveShaper))
            return
        }
        if let overdrive = waveNode as? OverdriveWaveEffect {
            map.addNode(WaveMap.nodeFromOverdrive(overdrive))
            return
        }
        assert(false)
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
                        Interface(name: "in 1", model: sum.input1),
                        Interface(name: "in 2", model: sum.input2),
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
}

public class WaveMapController: NSViewController {
    weak var mapViewController: MapViewController!
    public var creator: SoundNetworkElementsCreator!
    public var waveMap: WaveMap!
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destinationController as? MapViewController {
            mapViewController.map = waveMap.map
            self.mapViewController = mapViewController
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        waveMap.map.select = { node in
            if let oscilator = node.model as? Oscilator {
                let oscilatorController = OscilatorViewController.make()
                oscilatorController.oscilator = oscilator
                self.presentViewControllerAsModalWindow(oscilatorController)
            }
            if let envelope = node.model as? EnvelopeFunction {
                let envelopeViewController = EnvelopeViewController.make()
                envelopeViewController.envelopeFunction = envelope
                self.presentViewControllerAsModalWindow(envelopeViewController)
            }
            if let sampler = node.model as? Sampler {
                let samplerViewController = NSStoryboard(name: "Sampler", bundle: Bundle(identifier: "org.cocoapods.GuitarMidi")!).instantiateInitialController() as! SamplerViewController
                samplerViewController.sampler = sampler
                self.presentViewControllerAsModalWindow(samplerViewController)
            }
            if let waveShaper = node.model as? WaveShaper {
                let waveShaperViewController = NSStoryboard(name: "WaveShaper", bundle: Bundle(identifier: "org.cocoapods.GuitarMidi")!).instantiateInitialController() as! WaveShaperViewController
                waveShaperViewController.waveShaper = waveShaper
                self.presentViewControllerAsModalWindow(waveShaperViewController)
            }
            if let constant = node.model as? Constant {
                let constantViewController = ConstantViewController.make()
                constantViewController.constant = constant
                self.presentViewControllerAsModalWindow(constantViewController)
            }
        }
    }
    
    @IBAction func newOscilator(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeOscilator())
    }
    
    @IBAction func newSampler(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeSampler())
    }
    
    @IBAction func newEnvelope(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeEnvelope())
    }
    
    @IBAction func newConstant(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeConstant())
    }
    
    @IBAction func newAmp(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeAmp())
    }
    
    @IBAction func newSum(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeSum())
    }
    
    @IBAction func newWaveShaper(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeWaveShaper())
    }
    
    @IBAction func newOverdrive(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeOverdrive())
    }
}

extension Map {
    static func wave() -> Map {
        let map = Map{ (lhs, rhs) in
            
            if (with(lhs: lhs.1.model, rhs: rhs.1.model) { (input: SignalInput, output: SignalOutput) in
                input.output = output
            }) {return true}
            
            if (with(lhs: lhs.1.model, rhs: rhs.1.model) { (variable: FunctionVariable, variableSetter: FunctionVariableSetter) in
                variableSetter(variable)
            }) {return true}
            
            if (with(lhs: lhs.1.model, rhs: rhs.1.model) { (output: SignalOutput, waveMap: WaveMap) in
                waveMap.output.output = output
            }) {return true}
            
            return false
        }
        
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
