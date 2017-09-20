//
//  WaveEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

protocol Playing {
    func on()
    func off()
}

extension Playing {
    func on() {}
    func off() {}
}

protocol WaveEffect: Playing {
    func apply(input: Double) -> Double
}

class AmpWaveEffect: WaveEffect {
    var gain: FunctionVariable = 1.0
    
    func apply(input: Double) -> Double {
        return input * gain.value
    }
    
    func on() {
        gain.on()
    }
    
    func off() {
        gain.off()
    }
}
