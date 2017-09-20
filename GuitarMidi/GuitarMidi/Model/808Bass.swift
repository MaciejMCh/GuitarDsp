//
//  808Bass.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

let halfToneToScale: (Double) -> Double = {pow(2, $0 / 12)}

class Bass808: Playing {
    var oscilators: [Oscilator] = [Oscilator()]
    var effects: [WaveEffect] = [AmpWaveEffect()]
    
    func on() {
        for oscilator in oscilators {
            oscilator.on()
        }
        for effect in effects {
            effect.on()
        }
    }
    
    func off() {
        for oscilator in oscilators {
            oscilator.off()
        }
        for effect in effects {
            effect.off()
        }
    }
    
    func nextSample(frequency: Double) -> Double {
        var processingSample = oscilators.map{$0.waveGenerator.nextSample(frequency: frequency * halfToneToScale($0.tune.value)) * $0.volume.value}.reduce(0, +)
        
        for effect in effects {
            processingSample = effect.apply(input: processingSample)
        }
        
        return processingSample
    }
}
