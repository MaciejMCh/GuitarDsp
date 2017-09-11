
//  MidiOutputEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 05.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

class MidiOutputEffect: NSObject, Effect {
    let samplingSettings: SamplingSettings
    let pitchDetector: PitchDetector
    let sineWaveGenerator: SineWaveGenerator
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        pitchDetector = PitchDetector(samplingSettings: samplingSettings)
        sineWaveGenerator = SineWaveGenerator()
        super.init()
    }
    
    func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        var inputSignal: [Float] = Array(repeating: 0, count: Int(samplingSettings.framesPerPacket))
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            inputSignal[i] = inputSample.amp.advanced(by: i).pointee
        }
        
        let frequency = pitchDetector.detectPitch(inputSignal: inputSignal)
        debugPrint(frequency)
        
        let sineWave = sineWaveGenerator.generate(samples: 128, frequency: frequency * 0.00001)
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            outputBuffer.advanced(by: i).pointee = sineWave[i]
        }
        
//        let f: Float = 0.01
//        let s: Int = 128
//
//        var r: [Float] = []
//
//        r.append(contentsOf: sineWaveGenerator.generate(samples: s, frequency: f))
//        r.append(contentsOf: sineWaveGenerator.generate(samples: s, frequency: f))
//        r.append(contentsOf: sineWaveGenerator.generate(samples: s, frequency: f))
//        let str = r.map{"\($0) "}.reduce("", +)
        
//        debugPrint(str)
    }
}
