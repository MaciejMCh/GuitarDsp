//
//  ChannelPlayerEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 25.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

public protocol Channel: Playing {
    func nextSample() -> Double
}
extension Sampler: Channel {}
extension Bass808: Channel {}

protocol MidiPlayer: Playing {
    func setFrequency(_ frequency: Double)
}

public class ChannelPlayer: MidiPlayer {
    static var xd: ChannelPlayer!
    public var channels: [Channel] = []
    
    init() {
        ChannelPlayer.xd = self
    }
    
    public func setFrequency(_ frequency: Double) {
        for channel in channels {
            (channel as? MidiPlayer)?.setFrequency(frequency)
        }
    }
    
    public func on() {
        for channel in channels {
            channel.on()
        }
    }
    
    public func off() {
        for channel in channels {
            channel.off()
        }
    }
    
    public func nextSample() -> Double {
        return channels.map{$0.nextSample()}.reduce(0.0, +)
    }
}

public class ChannelPlayerEffect: NSObject, Effect {
    private let samplingSettings: SamplingSettings
    public let channelPlayer = ChannelPlayer()
    let midiOutput: MidiOutput
    
    public init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        midiOutput = MidiOutput(samplingSettings: samplingSettings)
    }
    
    public func play(channel: Channel) {
        channelPlayer.channels.append(channel)
    }
    
    public func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        var buffer: [Float] = Array(repeating: 0, count: Int(samplingSettings.framesPerPacket))
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            buffer[i] = inputSample.amp.advanced(by: i).pointee
        }
        
            for event in midiOutput.detectEvents(buffer: buffer) {
                switch event {
                case .on: channelPlayer.on()
                case .off: channelPlayer.off()
                case .frequency(let frequency): channelPlayer.setFrequency(frequency)
                }
            }
        
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            outputBuffer.advanced(by: i).pointee = Float(channelPlayer.nextSample())
        }
    }
}
