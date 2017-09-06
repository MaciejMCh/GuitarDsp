
//  MidiOutputEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 05.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import Beethoven
import AVFoundation
import Pitchy
import Accelerate

class MidiOutputEffect: NSObject, Effect {
    let samplingSettings: SamplingSettings
    
    static func makeEstimator() -> Estimator {
//        return YINEstimator()
//        return BarycentricEstimator()
//        return QuadradicEstimator()
//        return HPSEstimator()
        return QuinnsFirstEstimator()
//        return JainsEstimator()
//        return QuinnsSecondEstimator()
//        return MaxValueEstimator()
    }
    
    private let fftFrameSize = 4096
    private let bufferLengthInFrames = 16
    private let signalBufferLengthInSamples: Int
    private let windowSignal: [Float]
    private let estimator = MidiOutputEffect.makeEstimator()
    private var signalBuffer: [Float]
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        signalBufferLengthInSamples = Int(samplingSettings.framesPerPacket) * bufferLengthInFrames
        signalBuffer = Array(repeating: 0, count: Int(self.samplingSettings.framesPerPacket) * bufferLengthInFrames)
        var windowSignal = [Float](repeating: 0, count: signalBufferLengthInSamples)
        vDSP_hann_window(&windowSignal, vDSP_Length(windowSignal.count), 0)
        self.windowSignal = windowSignal
        super.init()
    }
    
    func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        let frameSizeInSamples = Int(samplingSettings.framesPerPacket)
        
        var inputSignal: [Float] = Array(repeating: 0, count: frameSizeInSamples)
        for i in 0..<frameSizeInSamples {
            inputSignal[i] = inputSample.amp.advanced(by: i).pointee
        }
        
        var newSignalBuffer: [Float] = inputSignal.reversed()
        newSignalBuffer.append(contentsOf: signalBuffer[0..<(self.bufferLengthInFrames - 1) * frameSizeInSamples])
        
        signalBuffer = newSignalBuffer
        
        var paddedSignal: [Float] = Array(repeating: 0, count: fftFrameSize)
        
        let offset = (fftFrameSize / 2) - (signalBufferLengthInSamples / 2)
        for i in 0..<signalBufferLengthInSamples {
            paddedSignal[offset + i] = signalBuffer[i] * windowSignal[i]
        }
        
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(samplingSettings.frequency), channels: 1)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(fftFrameSize))
        
        if let channelData = buffer.floatChannelData {
            for i in 0..<fftFrameSize {
                channelData[0][i] = paddedSignal[i]
            }
            buffer.frameLength = buffer.frameCapacity
        }
        
        // PROCESSING
        let transformedBuffer = try! estimator.transformer.transform(buffer: buffer)
        let frequency = try! estimator.estimateFrequency(sampleRate: Float(samplingSettings.frequency), buffer: transformedBuffer)
        
        for i in 0..<Int(self.samplingSettings.framesPerPacket) {
            outputBuffer.advanced(by: i).pointee = sin(Float(time) * frequency * 0.0001)
            time += 1
        }
    }
    
    var time = 0
    // PROCESSING
}

/*
 4k     8k
 YIN    850
 BAR    580
 QUA    570
 HPS    X
 QU1    370
 JAI    370
 QU2    370
 MAX    400
 */
