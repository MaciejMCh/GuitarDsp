//
//  WaveGenerator.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

let sign: (Double) -> Double = {$0 > 0 ? 1 : -1}

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
        
        switch waveShape {
        case .sine: return sin(x)
        case .square: return sign(sin(x))
        case .triangle: return 0
        case .circle: return 0
        }
    }
}
