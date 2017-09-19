//
//  808Bass.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

let halfToneToScale: (Double) -> Double = {pow(2, $0 / 12)}

class Bass808 {
    var oscilators: [Oscilator] = [Oscilator()]
    private var isOn = false
    
    func on() {
        isOn = true
    }
    
    func off() {
        isOn = false
    }
    
    func nextSample(frequency: Double) -> Double {
        guard isOn else {return 0}
        return oscilators.map{$0.waveGenerator.nextSample(frequency: frequency * halfToneToScale($0.tune.value)) * $0.volume.value}.reduce(0, +)
    }
}

class Oscilator {
    var waveGenerator = WaveGenerator()
    var tune: FunctionVariable = -12
    var volume: FunctionVariable = 1
}
