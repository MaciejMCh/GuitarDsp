//
//  WaveGenerator.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 17.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

class WaveGenerator {
    private let frequencyFunction: FunctionVariable
    private var x: Double = 0
    
    init(frequencyFunction: FunctionVariable) {
        self.frequencyFunction = frequencyFunction
    }
    
    func nextSample() -> Double {
        let timeShift = frequencyFunction.value * 0.01
        x += timeShift
        return sin(x)
    }
}
