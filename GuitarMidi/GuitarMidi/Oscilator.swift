//
//  Oscilator.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

public class Oscilator: Playing {
    let samplingSettings: SamplingSettings
    public var waveGenerator: WaveGenerator
    public var tune: FunctionVariable = -12
    public var volume: FunctionVariable = 0.2
    
    public init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        waveGenerator = WaveGenerator(samplingSettings: samplingSettings)
    }
    
    public func on() {
        tune.on()
        volume.on()
    }
    
    public func off() {
        tune.off()
        volume.off()
    }
}
