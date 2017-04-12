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
    
    func write(dry: UnsafePointer<Float>, wet: UnsafePointer<Float>, length: Int) {
        
        
//        asbd.mChannelsPerFrame = 2;
//        asbd.mBitsPerChannel   = 8 * floatByteSize;
//        asbd.mBytesPerFrame    = asbd.mChannelsPerFrame * floatByteSize;
//        asbd.mFramesPerPacket  = 1;
//        asbd.mBytesPerPacket   = asbd.mFramesPerPacket * asbd.mBytesPerFrame;
//        asbd.mFormatFlags      = kAudioFormatFlagIsFloat;
//        asbd.mFormatID         = kAudioFormatLinearPCM;
//        asbd.mSampleRate       = sampleRate;
//        asbd.mReserved         = 0;
        var outputFormat = AudioStreamBasicDescription()
//        outputFormat.mChannelsPerFrame = 2
//        outputFormat.mBitsPerChannel = UInt32(8.0 * Float(floatByteSize))
//        outputFormat.mBytesPerFrame = outputFormat.mChannelsPerFrame * UInt32(floatByteSize)
//        outputFormat.mFramesPerPacket = 1
//        outputFormat.mBytesPerPacket = outputFormat.mFramesPerPacket * outputFormat.mBytesPerFrame
//        outputFormat.mFormatFlags = kAudioFormatFlagIsFloat
//        outputFormat.mFormatID = kAudioFormatLinearPCM
//        outputFormat.mSampleRate = Double(samplingSettings.frequency)
//        outputFormat.mReserved = 0
        
//        AudioFileTypeID fileType = kAudioFileWAVEType;
//        AudioStreamBasicDescription clientFormat;
        let mChannels = UInt32(2)
        outputFormat.mSampleRate = 44100.0;
        outputFormat.mFormatID = kAudioFormatLinearPCM;
        outputFormat.mFormatFlags = 12;
        outputFormat.mBitsPerChannel = 32;
        outputFormat.mChannelsPerFrame = mChannels;
        outputFormat.mBytesPerFrame = 4*outputFormat.mChannelsPerFrame;
        outputFormat.mFramesPerPacket = 1;
        outputFormat.mBytesPerPacket = 4*outputFormat.mChannelsPerFrame;
        
//        var outputFormat = AudioStreamBasicDescription(mSampleRate: Float64(samplingSettings.frequency),
//                                                       mFormatID: kAudioFormatLinearPCM,
//                                                       mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked,
//                                                       mBytesPerPacket: 4,
//                                                       mFramesPerPacket: 1,
//                                                       mBytesPerFrame: 4,
//                                                       mChannelsPerFrame: 1,
//                                                       mBitsPerChannel: 32,
//                                                       mReserved: 0)
        
        var outputFile: AudioFileID?
        let outputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, "xd.wav" as CFString!, .cfurlposixPathStyle, false)!
        let s = AudioFileCreateWithURL(outputFileURL, kAudioFileWAVEType, &outputFormat, .eraseFile, &outputFile)
//        let duration = 3.0
//        let freq = 261.37
//        let amplitude = 0.3
        var sizeOfBuffer = UInt32(Int(length) * Int(MemoryLayout<Float32>.size) * 2)
        var audioBuffer: [Float] = Array(repeating: 0, count: length * 2)
        for i in 0..<length {
            audioBuffer[i * 2] = dry.advanced(by: i).pointee
            audioBuffer[i * 2 + 1] = wet.advanced(by: i).pointee
//            if i % 2 == 0 {
//                audioBuffer[i] = 0.5
//            } else {
//                audioBuffer[i] = -0.5
//            }
        }
//        for i in 0..<Int(outputFormat.mSampleRate * duration) {
//            audioBuffer[i] = Float(amplitude) * sinf(Float(i) * Float(freq) / Float(outputFormat.mSampleRate) * Float(2.0) * Float(M_PI))
//        }
//        for i in Int(outputFormat.mSampleRate * duration)..<Int(outputFormat.mSampleRate * duration * 2) {
//            audioBuffer[i] = Float(amplitude * 2) * sinf(Float(i) * Float(freq * 2) / Float(outputFormat.mSampleRate) * Float(2.0) * Float(M_PI))
//        }
        AudioFileWriteBytes(outputFile!, false, 0, &sizeOfBuffer, audioBuffer)
        AudioFileClose(outputFile!)
    }
}
