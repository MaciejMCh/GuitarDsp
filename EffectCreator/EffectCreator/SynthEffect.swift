//
//  SynthEffect.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 09.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

class SynthEffect: NSObject, Effect {
    private let samplingSettings: SamplingSettings
    private var time = Double(0)
    private let audioPlayer: RawAudioPlayer
    private let signal: Signal
    private var speed = 1.0
    private var it = Int(0)
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        let path = "/Users/maciejchmielewski/Desktop/p/hmm/GuitarDsp/EffectCreator/EffectCreator/zz.raw"
        let url = NSURL.fileURL(withPath: path)
        let data = try! Data.init(contentsOf: url)
        audioPlayer = RawAudioPlayer(samplingSettings: samplingSettings, data: data)
        
        var samples: [Float] = []
        for i in 0..<audioPlayer.rawAudio.length {
            samples.append(audioPlayer.rawAudio.buffer.advanced(by: Int(i)).pointee)
        }
        
        signal = Signal(samples: samples)
    }
    
    func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        let framesPerPacket = Int(samplingSettings.framesPerPacket)
        for i in 0..<framesPerPacket {
            outputBuffer.advanced(by: i).pointee = signal.atTime(time: time)
            time += speed
        }
        
        if it % 500 == 0 {
//            speed *= 1.0 + (1.0 / 12.0)
        }
        
        it += 1
    }
}

struct Signal {
    let samples: [Float]
    
    func atTime(time: Double) -> Float {
        let t = fmod(time, Double(samples.count))
//        while t >= Float(samples.count) {
//            t -= Float(samples.count)
//        }
        
        let bottomIndex = Int(floor(t))
        let topPower = Float(t - Double(bottomIndex))
        let bottomPower = 1.0 - topPower
        
        let bottomSample = samples[bottomIndex]
        let topSample = samples[(bottomIndex + 1) % samples.count]
        
        return (bottomSample * bottomPower) + (topSample * topPower)
    }
}
