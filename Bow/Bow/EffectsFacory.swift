//
//  EffectsFacory.swift
//  Bow
//
//  Created by Maciej Chmielewski on 30.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import GuitarMidi

struct EffectsFacory {
    let samplingSettings: SamplingSettings
    
    func all() -> [Effect] {
        return [makeChannelPlayer(), makeAmp(), makeDelay(), makeHarmonizer(), makePhaseVocoder(), makeReverb(), makeCompressor(), makeBitCrusher(), makeVibe(), makeFlanger(), makePhaser(), makeDistortion()]
    }
    
    func makeAmp() -> AmpEffect {
        return AmpEffect(samplingSettings: samplingSettings)
    }
    
    func makeDelay() -> DelayEffect {
        return DelayEffect(fadingFunctionA: 0.2, fadingFunctionB: 0.2, echoesCount: 3, samplingSettings: samplingSettings, timing: Timing(tactPart: .Half, tempo: 120))
    }
    
    func makeHarmonizer() -> HarmonizerEffect {
        return HarmonizerEffect(samplingSettings: samplingSettings)
    }
    
    func makePhaseVocoder() -> PhaseVocoderEffect {
        return PhaseVocoderEffect(samplingSettings: samplingSettings)
    }
    
    func makeReverb() -> ReverbEffect {
        return ReverbEffect(samplingSettings: samplingSettings)
    }
    
    func makeLooper() -> LooperEffect {
        return LooperEffect(samplingSettings: samplingSettings, banksCount: 5, tempo: 120, tactsCount: 2)
    }
    
    func makeCompressor() -> CompressorEffect {
        return CompressorEffect(samplingSettings: samplingSettings)
    }
    
    func makeBitCrusher() -> BitCrusherEffect {
        return BitCrusherEffect(samplingSettings: samplingSettings)
    }
    
    func makeVibe() -> VibeEffect {
        return VibeEffect(samplingSettings: samplingSettings)
    }
    
    func makeFlanger() -> FlangerEffect {
        return FlangerEffect(samplingSettings: samplingSettings)
    }
    
    func makePhaser() -> PhaserEffect {
        return PhaserEffect(samplingSettings: samplingSettings)
    }
    
    func makeDistortion() -> DistortionEffect {
        return DistortionEffect(samplingSettings: samplingSettings)
    }
    
    func makeChannelPlayer() -> ChannelPlayerEffect {
        let channelPlayerEffect = ChannelPlayerEffect(samplingSettings: samplingSettings)
        channelPlayerEffect.channels = [Bass808(samplingSettings: samplingSettings)]
        return channelPlayerEffect
    }
    
    func makeSampler() -> Sampler {
        return Sampler(audioFilePath: "/Users/maciejchmielewski/Documents/GuitarDsp/samples/440.wav", samplingSettings: samplingSettings)
    }
    
    func make808() -> Bass808 {
        return Bass808(samplingSettings: samplingSettings)
    }
}
