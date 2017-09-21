//
//  Sampler.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

class Sampler: Playing {
    private let audioPlayer: RawAudioPlayer
    private var time: Int = 0
    
    init(samplingSettings: SamplingSettings, fileName: String) {
        let bundle = Bundle(for: Sampler)
        let url = bundle.url(forResource: fileName, withExtension: "raw")!
        let data = try! Data.init(contentsOf: url)
        audioPlayer = RawAudioPlayer(samplingSettings: samplingSettings, data: data)
    }
    
    func on() {
        time = 0
    }
    
    func off() {
        
    }
    
    func nextSample() -> Double {
        defer {
            time += 1
        }
        
        if time < audioPlayer.rawAudio.length {
            return Double(audioPlayer.rawAudio.buffer.advanced(by: time).pointee)
        } else {
            return 0
        }
    }
}
