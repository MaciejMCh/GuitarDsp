//
//  WavWriter.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 12.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import AudioToolbox
import GuitarDsp

struct WavWriter {
    let samplingSettings: SamplingSettings
    
    func write() {
        var outputFormat = AudioStreamBasicDescription(mSampleRate: Float64(samplingSettings.frequency),
                                                       mFormatID: kAudioFormatLinearPCM,
                                                       mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked,
                                                       mBytesPerPacket: 4,
                                                       mFramesPerPacket: 1,
                                                       mBytesPerFrame: 4,
                                                       mChannelsPerFrame: 1,
                                                       mBitsPerChannel: 32,
                                                       mReserved: 0)
        
        var outputFile: AudioFileID?
        let outputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, "xd.wav" as CFString!, .cfurlposixPathStyle, false)!
        AudioFileCreateWithURL(outputFileURL, kAudioFileWAVEType, &outputFormat, .eraseFile, &outputFile)
        let duration = 3.0
        let freq = 261.37
        let amplitude = 0.3
        var sizeOfBuffer = UInt32(outputFormat.mSampleRate * duration * Double(MemoryLayout<Float32>.size))
        var audioBuffer = Array<Float>(repeating: 0, count: Int(outputFormat.mSampleRate * duration))
        for i in 0..<Int(outputFormat.mSampleRate * duration) {
            audioBuffer[i] = Float(amplitude) * sinf(Float(i) * Float(freq) / Float(outputFormat.mSampleRate) * Float(2.0) * Float(M_PI))
        }
        AudioFileWriteBytes(outputFile!, false, 0, &sizeOfBuffer, audioBuffer)
        AudioFileClose(outputFile!)
    }
}
