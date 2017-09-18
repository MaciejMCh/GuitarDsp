//
//  WaveEffect.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 17.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

enum WaveEffect {
    case overdrive(level: FunctionVariable)
    case foldback(level: FunctionVariable, bounce: FunctionVariable)
    
    func apply(sample: Double) -> Double {
        switch self {
        case .overdrive(let level): return min(level.value, abs(sample)) / level.value * sign(sample)
        case .foldback(let level, let bounce):
            guard abs(sample) > level.value else {return sample}
            return sample + ((abs(sample) - level.value) * -sign(sample) * bounce.value * 2)
        }
    }
}
