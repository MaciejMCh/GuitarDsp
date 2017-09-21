//
//  Oscilator.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

class Oscilator: Playing {
    let samplingSettings: SamplingSettings
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
    }
    
    var waveGenerator = WaveGenerator()
    var tune: FunctionVariable = -12
    var volume: FunctionVariable = 0.2
    
    func on() {
        tune.on()
        volume.on()
    }
    
    func off() {
        tune.off()
        volume.off()
    }
}
