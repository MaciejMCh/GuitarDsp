//
//  WaveGenerator.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

enum WaveShape {
    case sine
    case square
    case triangle
    case circle
}

class WaveGenerator {
    var waveShape: WaveShape = .sine
    var frequencyFunction: FunctionVariable = 1.0
    
    private var x: Double = 0
    
    init() {}
    
    func nextSample(frequency: Double) -> Double {
        let timeShift = frequency * frequencyFunction.value * 0.01
        x += timeShift
        return sin(x)
    }
}
