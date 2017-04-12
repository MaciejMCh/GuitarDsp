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
    let dryData: NSMutableData = NSMutableData()
    let wetData: NSMutableData = NSMutableData()
    
    override func processBuffer(_ buffer: UnsafeMutablePointer<Float>!) {
        super.processBuffer(buffer)
        dryData.append(buffer, length: Int(samplingSettings.packetByteSize))
        wetData.append(outputBuffer, length: Int(samplingSettings.packetByteSize))
    }
    
    func saveData() {
        
    }
}
