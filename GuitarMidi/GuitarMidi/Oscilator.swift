//
//  Oscilator.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

public class Oscilator: Playing, MidiPlayer {
    let samplingSettings: SamplingSettings
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.nextOutput(time: $0) ?? 0}}()
    public let waveGenerator: WaveGenerator
    public var tune: FunctionVariable = -12
    private var frequency: Double = 0
    
    public init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        waveGenerator = WaveGenerator(samplingSettings: samplingSettings)
    }
    
    private func nextOutput(time: Int) -> Double {
        return waveGenerator.nextSample(frequency: frequency * halfToneToScale(tune.value))
    }
    
    public func on() {
        tune.on()
    }
    
    public func off() {
        tune.off()
    }
    
    func setFrequency(_ frequency: Double) {
        self.frequency = frequency
    }
}
