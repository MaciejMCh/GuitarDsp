//
//  SineWaveGenerator.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 06.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

class SineWaveGenerator {
    private var lastValue: Float = 0
    private var lastDerivative: Float = 1
    
    func generate(samples: Int, frequency: Float) -> [Float] {
        let phaseShift = (lastDerivative > 0 ? asin(lastValue) : acos(lastValue) + (Float.pi / 2)) + frequency
        
        var wave: [Float] = Array(repeating: 0, count: samples)
        
        for i in 0..<samples {
            wave[i] = sin((Float(i) * frequency) + phaseShift)
        }
        
        lastValue = wave.last ?? 0
        let preLastValue = wave.dropLast(2).last ?? 0
        lastDerivative = lastValue - preLastValue
        
        return wave
    }
}
