//
//  ChannelPlayerEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 25.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

public let channelPlayerXd = ChannelPlayerEffect(samplingSettings: AudioInterface.shared().samplingSettings)

public protocol Channel: Playing {
    func nextSample() -> Double
}
extension Sampler: Channel {}
extension Bass808: Channel {}

public class ChannelPlayerEffect: NSObject, Effect {
    private let samplingSettings: SamplingSettings
    private var channels: [Channel] = []
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
    }
    
    public func play(channel: Channel) {
        channels.append(channel)
    }
    
    public func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            outputBuffer.advanced(by: i).pointee = Float(channels.map{$0.nextSample()}.reduce(0.0, +))
        }
    }
}
