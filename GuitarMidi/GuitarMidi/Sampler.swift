//
//  Sampler2.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 22.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import EZAudio

struct AudioFile {
    let samples: [Float]
    let duration: Float
    
    static func load(filePath: String, samplingSettings: SamplingSettings) -> AudioFile {
        let url = URL(fileURLWithPath: filePath)
        let audioFile = EZAudioFile(url: url)!
        let samplesCount = Double(samplingSettings.frequency) * audioFile.duration
        let data = audioFile.getWaveformData(withNumberOfPoints: UInt32(samplesCount))!
        var buffer: [Float] = Array.init(repeating: 0, count: Int(data.bufferSize))
        memcpy(&buffer, data.buffer(forChannel: 0), Int(data.bufferSize) * MemoryLayout<Float>.size)
        return AudioFile(samples: buffer, duration: Float(audioFile.duration))
    }
}

class Sampler: Playing {
    let samplingSettings: SamplingSettings
    var volume: FunctionVariable = EnvelopeFunction()
    var audioFilePath: String {
        didSet {
            audioFile = .load(filePath: audioFilePath, samplingSettings: samplingSettings)
        }
    }
    
    private(set) var audioFile: AudioFile
    private var time = 0
    
    init(audioFilePath: String, samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        self.audioFilePath = audioFilePath
        audioFile = .load(filePath: audioFilePath, samplingSettings: samplingSettings)
    }
    
    func nextSample() -> Double {
        defer {
            time += 1
        }
        
        if time < audioFile.samples.count {
            return Double(audioFile.samples[time]) * volume.value
        } else {
            return 0
        }
    }
    
    func on() {
         volume.on()
        time = 0
    }
    
    func off() {
        volume.off()
    }
}
