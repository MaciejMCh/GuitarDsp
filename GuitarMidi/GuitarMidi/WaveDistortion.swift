//
//  WaveDistortion.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 28.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

struct OverdriveWaveEffect: WaveEffect {
    let treshold: FunctionVariable
    
    func apply(input: Double) -> Double {
        return min(input, treshold.value)
    }
}

struct FoldbackWaveEffect: WaveEffect {
    var treshold: FunctionVariable
    
    func apply(input: Double) -> Double {
        let diff = input - treshold.value
        return diff > 0 ? input - (2 * diff) : input
    }
}
