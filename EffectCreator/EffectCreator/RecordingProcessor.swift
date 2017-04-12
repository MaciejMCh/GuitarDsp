//
//  RecordingProcessor.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 12.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

final class RecordingProcessor: Processor {
    var dryBuffer: [Float] = []
    var wetBuffer: [Float] = []
    
    override init(samplingSettings: SamplingSettings, tempo: Float) {
        super.init(samplingSettings: samplingSettings, tempo: tempo)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSApplicationWillTerminate, object: nil, queue: nil) { [weak self] _ in
            self?.saveData()
        }
    }
    
    override func processBuffer(_ buffer: UnsafeMutablePointer<Float>!) {
        super.processBuffer(buffer)
        
        for i in 0..<samplingSettings.framesPerPacket {
            dryBuffer.append(buffer.advanced(by: Int(i)).pointee)
            wetBuffer.append(outputBuffer.advanced(by: Int(i)).pointee)
        }
    }
    
    func saveData() {
        let dataLength = min(dryBuffer.count, wetBuffer.count)
        WavWriter(samplingSettings: samplingSettings).write(dry: &dryBuffer, wet: &wetBuffer, length: dataLength)
    }
}
