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
    let sineWaveGenerator = SineWaveGenerator()
    
    var pointer: Float = 0
    
    private lazy var sineWave: [Float] = {self.sineWaveGenerator.generate()}()
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
    }
    
    var p: Float = 0
    func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        
//        p += 0.001
//        p = fmodf(p, 1)
//        sineWave = sineWaveGenerator.generate(percent: p)
        
        for i in 0..<samplingSettings.framesPerPacket {
            outputBuffer.advanced(by: Int(i)).pointee = sineWave[Int(pointer)]
            
            pointer = pointer + 1
            pointer = fmodf(pointer, Float(sineWave.count))
        }
    }
}
