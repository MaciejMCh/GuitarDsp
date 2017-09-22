//
//  Sampler2.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 22.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import EZAudioOSX

class Sampler2 {
    let buffer: [Float]
    
    init(fileName: String, fileExtension: String) {
        let url = Bundle(for: Sampler2).url(forResource: fileName, withExtension: fileExtension)
        let audioFile = EZAudioFile(url: url)!
        let data = audioFile.getWaveformData()!
        var buffer: [Float] = Array.init(repeating: 0, count: Int(data.bufferSize))
        memcpy(&buffer, data.buffer(forChannel: 0), Int(data.bufferSize) * MemoryLayout<Float>.size)
        
        self.buffer = buffer
    }
}
