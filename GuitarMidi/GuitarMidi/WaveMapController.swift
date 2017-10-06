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

class WaveMapController: NSViewController {
    weak var mapViewController: MapViewController!
    var creator: SoundNetworkElementsCreator!
    var map: Map!
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destinationController as? MapViewController {
            mapViewController.map = map
            self.mapViewController = mapViewController
        }
    }
    
    @IBAction func newOscilator(_ sender: Any?) {
        map.addNode(Map.nodeFromOscilator(creator.makeOscilator()))
    }
    
    @IBAction func newSampler(_ sender: Any?) {
        map.addNode(Map.nodeFromSampler(creator.makeSampler()))
    }
    
    @IBAction func newEnvelope(_ sender: Any?) {
        map.addNode(Map.nodeFromEnvelope(creator.makeEnvelope()))
    }
    
    @IBAction func newConstant(_ sender: Any?) {
        map.addNode(Map.nodeFromConstant(creator.makeConstant()))
    }
    
    @IBAction func newAmp(_ sender: Any?) {
        map.addNode(Map.nodeFromAmp(creator.makeAmp()))
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
    
    fileprivate static func nodeFromConstant(_ constant: Double) -> Node {
        return Node(name: "constant",
                    interfaces: [Interface(name: "out", model: constant.output)],
                    model: constant)
    }
    
    fileprivate static func nodeFromSampler(_ sampler: Sampler) -> Node {
        return Node(name: "sampler",
                    interfaces: [Interface(name: "out", model: sampler.output)],
                    model: sampler)
    }
    
}

extension Oscilator {
    var tuneSetter: FunctionVariableSetter {return {self.tune = $0}}
}

extension AmpWaveEffect {
    var gainSetter: FunctionVariableSetter {return {self.gain = $0}}
}
