//
//  ChannelPlayerEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 25.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

let channelPlayerXd = ChannelPlayerEffect(samplingSettings: AudioInterface.shared().samplingSettings)

protocol Channel: Playing {
    func nextSample() -> Double
}
extension Sampler: Channel {}

class ChannelPlayerEffect: NSObject, Effect {
    private let samplingSettings: SamplingSettings
    private var channels: [Channel] = []
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
    }
    
    func play(channel: Channel) {
        channels.removeAll()
        channels.append(channel)
    }
    
    func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            outputBuffer.advanced(by: i).pointee = Float(channels.map{$0.nextSample()}.reduce(0.0, +))
        }
    }
}
