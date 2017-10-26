//
//  AudioFileReader.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 25.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

#if os(OSX)
    import EZAudio

    extension AudioFile {
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
#endif

#if os(iOS)
    extension AudioFile {
        static func load(filePath: String, samplingSettings: SamplingSettings) -> AudioFile {
            return "" as! AudioFile
        }
    }
#endif
