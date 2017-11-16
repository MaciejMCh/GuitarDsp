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
    import AVFoundation
    
    extension AudioFile {
        static func load(filePath: String, samplingSettings: SamplingSettings) -> AudioFile {
            let mySourceURL = URL(fileURLWithPath: filePath)
            let file: AVAudioFile!
            do {
                file = try AVAudioFile(forReading: mySourceURL)
            } catch {
                print("Error:", error)
                return "" as! AudioFile
            }
            let totSamples = file.length
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)!
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totSamples))!
            do {
                try file.read(into: buffer)
            } catch (let e) {
                print("Error:", e)
                return "" as! AudioFile
            }
            let floatArray = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count:Int(buffer.frameLength)))
            let duration = Float(floatArray.count) / Float(file.fileFormat.sampleRate)
            return AudioFile(samples: floatArray, duration: duration)
        }
    }
#endif
