//
//  Bass808Effect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 19.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

class Bass808Effect: NSObject, Effect {
    let samplingSettings: SamplingSettings
    
    var bass808: Bass808 {
        return bass808xD
    }
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
    }
    
    func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        bass808.frequency = 100
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            outputBuffer.advanced(by: i).pointee = Float(bass808.nextSample())
        }
    }
}
