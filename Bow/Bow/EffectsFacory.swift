//
//  EffectsFacory.swift
//  Bow
//
//  Created by Maciej Chmielewski on 30.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

struct EffectsFacory {
    let samplingSettings: SamplingSettings
    
    let all: () -> [Effect]
    
    func makeAmp() -> AmpEffect {
        return AmpEffect(samplingSettings: samplingSettings)
    }
}
