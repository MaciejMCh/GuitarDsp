//
//  Test.swift
//  Bow
//
//  Created by Maciej Chmielewski on 27.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarMidi
import GuitarDsp

func testChannelPlayerSerialization() {
    let samplingSettings = SamplingSettings(frequency: 100, packetByteSize: 100, framesPerPacket: 100, channelsCount: 100)
    
    let makeChannelPlayerInstance: () -> EffectPrototype.Instance = {
        let channelPlayerEffect = ChannelPlayerEffect(samplingSettings: samplingSettings)
        let instance = EffectPrototype.Instance.channelPlayer(channelPlayerEffect)
        return instance
    }
    
    let in1 = makeChannelPlayerInstance()
    let in1c = makeChannelPlayerInstance()
    let c1 = in1.effect as! ChannelPlayerEffect
    let c2 = in1c.effect as! ChannelPlayerEffect
    
    let clone = {
        EffectPrototype.configure(effect: in1c, configuration: EffectPrototype.configuration(effect: in1))
    }
    
    // instance
    clone()
    assert((in1.effect as! ChannelPlayerEffect).channels.count == (in1c.effect as! ChannelPlayerEffect).channels.count)
    
    // serialize sampler
    c1.channels = [(Sampler(audioFilePath: "/Users/maciejchmielewski/Documents/GuitarDsp/samples/440.wav", samplingSettings: samplingSettings))]
    clone()
    assert(c2.channels.count == 1)
    
    // serialize envelope
    (c1.channels[0] as! Sampler).volume = EnvelopeFunction()
    clone()
    assert((c2.channels[0] as! Sampler).volume is EnvelopeFunction)
    
    // serialize bezier
    ((c1.channels[0] as! Sampler).volume as! EnvelopeFunction).attackBezier = .fadeIn
    clone()
    assert(((c2.channels[0] as! Sampler).volume as! EnvelopeFunction).attackBezier != nil)
    
    // serialize 808
    c1.channels = [Bass808(samplingSettings: samplingSettings)]
    clone()
    assert(c2.channels[0] is Bass808)
    
    debugPrint("asd")
}
