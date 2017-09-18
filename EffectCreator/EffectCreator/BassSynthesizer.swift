//
//  BassSynthesizer.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 17.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

class BassSynthesizer {
    var waveGenerator: WaveGenerator
    var effects: [WaveEffect] = []
    
    init(waveGenerator: WaveGenerator) {
        self.waveGenerator = waveGenerator
    }
    
    func nextSample() -> Double {
        var sample = waveGenerator.nextSample()
        for effect in effects {
            sample = effect.apply(sample: sample)
        }
        return sample
    }
}
