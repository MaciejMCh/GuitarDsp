//
//  Sampler2.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 22.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import EZAudioOSX

struct AudioFile {
    let samples: [Float]
    let ratio: Double
    
    static func load(filePath: String) -> AudioFile {
        let url = URL(fileURLWithPath: filePath)
        let audioFile = EZAudioFile(url: url)!
        let data = audioFile.getWaveformData()!
        var buffer: [Float] = Array.init(repeating: 0, count: Int(data.bufferSize))
        memcpy(&buffer, data.buffer(forChannel: 0), Int(data.bufferSize) * MemoryLayout<Float>.size)
        
        return AudioFile(samples: buffer, ratio: 0)
    }
}

class Sampler: Playing {
    var volume = 1.0
    var audioFilePath: String {
        didSet {
            audioFile = .load(filePath: audioFilePath)
        }
    }
    
    private(set) var audioFile: AudioFile
    private var time = 0
    
    init(audioFilePath: String) {
        self.audioFilePath = audioFilePath
        audioFile = .load(filePath: audioFilePath)
    }
    
    func nextSample() -> Double {
        defer {
            time += 1
        }
        
        if time < audioFile.samples.count {
            return Double(audioFile.samples[time])
        } else {
            return 0
        }
    }
    
    func on() {
        time = 0
    }
}
