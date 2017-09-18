//
//  SineWavePlayerEffect.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 14.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

class SineWavePlayerEffect: NSObject, Effect {
    let samplingSettings: SamplingSettings
    let bassSynth: BassSynthesizer
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        
        let toneFrequency = 1.2
        let sineWaveGenerator = WaveGenerator(frequencyFunction: FadeInOutFunction(from: toneFrequency * 1.15, to: toneFrequency, duration: 30000))
        bassSynth = BassSynthesizer(waveGenerator: sineWaveGenerator)
//        bassSynth.effects.append(.foldback(level: 0.9, bounce: 1))
//        bassSynth.effects.append(.foldback(level: 0.8, bounce: 1))
//        bassSynth.effects.append(.overdrive(level: 0.9))
    }
    
    func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        for i in 0..<samplingSettings.framesPerPacket {
            outputBuffer.advanced(by: Int(i)).pointee = Float(bassSynth.nextSample())
        }
    }
}
