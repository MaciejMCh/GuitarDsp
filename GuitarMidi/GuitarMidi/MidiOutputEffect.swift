
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
    
    
//    let estimator = YINEstimator()
//    let estimator = BarycentricEstimator()
//    let estimator = QuadradicEstimator()
//    let estimator = HPSEstimator()
    let estimator = QuinnsFirstEstimator()
//    let estimator = JainsEstimator()
//    let estimator = QuinnsSecondEstimator()
//    let estimator = MaxValueEstimator()
    
    
    
    let samplingSettings: SamplingSettings
    
    let bufferLengthInFrames = 16
    lazy var signalBuffer: [Float] = {
        return Array.init(repeating: 0, count: Int(self.samplingSettings.framesPerPacket) * self.bufferLengthInFrames)
    }()
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        super.init()
    }
    
    func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        let frameSizeInSamples = Int(samplingSettings.framesPerPacket)
//        memcpy(&self.signalBuffer[frameSizeInSamples], &self.signalBuffer[0], (self.bufferLengthInFrames - 1) * frameSizeInSamples * MemoryLayout<Float>.size)
//        memcpy(&self.signalBuffer[frameSizeInSamples], &self.signalBuffer[0], Int(samplingSettings.packetByteSize))
//        memcpy(&self.signalBuffer[0], inputSample.amp, Int(samplingSettings.packetByteSize))
        
        var inputSignal: [Float] = Array.init(repeating: 0, count: frameSizeInSamples)
        for i in 0..<frameSizeInSamples {
            inputSignal[i] = inputSample.amp.advanced(by: i).pointee
        }
        
        var newSignalBuffer: [Float] = inputSignal.reversed()
//        newSignalBuffer.append(contentsOf: signalBuffer[0..<127])
        let zz = (self.bufferLengthInFrames - 1) * frameSizeInSamples
        newSignalBuffer.append(contentsOf: signalBuffer[0..<zz])
        
        signalBuffer = newSignalBuffer
        
        
//        let string = self.signalBuffer.map{String($0) + " "}.reduce("", +)
        
//        for (k = 0; k < fftFrameSize;k++) {
        let fftFrameSize = 4096
//        let fftFrameSize = 4096 * 2
        let signalSize = Int(self.samplingSettings.framesPerPacket) * self.bufferLengthInFrames
        var windowedSignal: [Float] = Array(repeating: 0, count: fftFrameSize)
        
        var window = [Float](repeating: 0, count: signalSize)
        vDSP_hann_window( &window, vDSP_Length(window.count), 0 )
        
        let offset = (fftFrameSize / 2) - (signalSize / 2)
        for i in 0..<signalSize {
            windowedSignal[offset + i] = signalBuffer[i] * window[i]
        }
        
        
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(samplingSettings.frequency), channels: 1)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(fftFrameSize))
        
        if let channelData = buffer.floatChannelData {
            for i in 0..<Int(fftFrameSize) {
                channelData[0][i] = windowedSignal[i]
                
//                outputBuffer.advanced(by: i).pointee = inputSample.amp.advanced(by: i).pointee
            }
            buffer.frameLength = buffer.frameCapacity
        }
        
        let transformedBuffer = try! estimator.transformer.transform(buffer: buffer)
        let frequency = try! estimator.estimateFrequency(sampleRate: Float(samplingSettings.frequency), buffer: transformedBuffer)
        
        for i in 0..<Int(self.samplingSettings.framesPerPacket) {
            outputBuffer.advanced(by: i).pointee = 0
        }
        
//        debugPrint(frequency)
        
//        if let xd = try? Pitch(frequency: Double(frequency)) {
//            let freq: Float
//            if xd.note.index >= 7 && xd.note.index <= 19 {
//                freq = Float(pow(1.0 + (1.0 / 12.0), Float(xd.note.index - 7)))
//            } else {
//                freq = 0
//            }
            for i in 0..<Int(self.samplingSettings.framesPerPacket) {
                outputBuffer.advanced(by: i).pointee = sin(Float(time) * frequency * 0.0001)
                time += 1
            }
//        }
    }
    
    var time = 0
}
