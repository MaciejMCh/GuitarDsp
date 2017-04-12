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
        var outputFormat = AudioStreamBasicDescription()
        let mChannels = UInt32(2)
        outputFormat.mSampleRate = 44100.0;
        outputFormat.mFormatID = kAudioFormatLinearPCM;
        outputFormat.mFormatFlags = 9;
        outputFormat.mBitsPerChannel = 32;
        outputFormat.mChannelsPerFrame = mChannels;
        outputFormat.mBytesPerFrame = 4 * outputFormat.mChannelsPerFrame;
        outputFormat.mFramesPerPacket = 1;
        outputFormat.mBytesPerPacket = 4 * outputFormat.mChannelsPerFrame;
        
        var outputFile: AudioFileID?
        let outputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, "effect_development.wav" as CFString!, .cfurlposixPathStyle, false)!
        AudioFileCreateWithURL(outputFileURL, kAudioFileWAVEType, &outputFormat, .eraseFile, &outputFile)
        
        var sizeOfBuffer = UInt32(Int(length) * Int(MemoryLayout<Float32>.size) * 2)
        var audioBuffer: [Float] = Array(repeating: 0, count: length * 2)
        for i in 0..<length {
            audioBuffer[i * 2] = dry.advanced(by: i).pointee
            audioBuffer[i * 2 + 1] = wet.advanced(by: i).pointee
        }
        
        AudioFileWriteBytes(outputFile!, false, 0, &sizeOfBuffer, audioBuffer)
        AudioFileClose(outputFile!)
    }
}
