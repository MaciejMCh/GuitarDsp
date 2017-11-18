//
//  Oscilator.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

public class Oscilator: Playing, MidiPlayer, WaveNode {
    public let id: String
    let samplingSettings: SamplingSettings
    let ff = FlipFlop()
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.next(time: $0) ?? 0}}()
    public var waveGenerator: WaveGenerator
    public var tune: FunctionVariable = Constant(value: -12)
    private var frequency: Double = 1.0
    
    public init(samplingSettings: SamplingSettings, id: String? = nil) {
        self.samplingSettings = samplingSettings
        self.id = id ?? IdGenerator.next()
        waveGenerator = WaveGenerator(samplingSettings: samplingSettings)
    }
    
    public func next(time: Int) -> Double {
//        return 1
        let v = ff.value(time: time) {self.waveGenerator.nextSample(frequency: self.frequency * halfToneToScale(self.tune.next(time: time)))}
//        debugPrint(v)
        return v
    }
    
    public func on() {
        tune.on()
    }
    
    public func off() {
        tune.off()
    }
    
    public func setFrequency(_ frequency: Double) {
        self.frequency = frequency
    }
}
