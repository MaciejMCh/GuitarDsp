//
//  808Bass.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

let halfToneToScale: (Double) -> Double = {pow(2, $0 / 12)}

public class Bass808: Playing, MidiPlayer {
    let samplingSettings: SamplingSettings
    public var samplers: [Sampler] = []
    
    public lazy var oscilators: [Oscilator] = {
        let single = Oscilator(samplingSettings: self.samplingSettings)
        single.tune = -12
        single.volume = 1
        
        let triple1 = Oscilator(samplingSettings: self.samplingSettings)
        triple1.tune = -12
        triple1.volume = 0.5
        
        let triple2 = Oscilator(samplingSettings: self.samplingSettings)
        triple2.tune = 7
        triple2.volume = 0.3
        
        let triple3 = Oscilator(samplingSettings: self.samplingSettings)
        triple3.tune = 0
        triple3.volume = 0.2
        
        return [single]
//        return [triple1, triple2, triple3]
    }()
    
    public lazy var effects: [WaveEffect] = {
        let ampWaveEffect = AmpWaveEffect()
        let envelope = EnvelopeFunction()
        envelope.duration = self.samplingSettings.samplesInSecond()
        envelope.delay = 0
        envelope.attack = 0.02
        envelope.hold = 0.2
        envelope.decay = 2
        envelope.sustain = 0
        envelope.release = 0.15
        envelope.volume = 1.0
        envelope.attackBezier = CubicBezier(p1: .init(x: 1, y: 0), p2: .init(x: 1, y: 0))
        envelope.decayBezier = CubicBezier(p1: .init(x: 0, y: 1), p2: .init(x: 0, y: 1))
        envelope.releaseBezier = CubicBezier(p1: .init(x: 0, y: 1), p2: .init(x: 0, y: 1))
        ampWaveEffect.gain = envelope
        
        let waveShaper = WaveShaper()
        waveShaper.cubicBezier = CubicBezier(p1: .init(x: 0, y: 1), p2: .init(x: 0, y: 1))
        
        let foldback = FoldbackWaveEffect(treshold: 0.8)
        
//        return [ampWaveEffect]
        return [waveShaper, foldback, ampWaveEffect]
    }()
    
    public init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
    }
    
    public func on() {
        for oscilator in oscilators {
            oscilator.on()
        }
        for effect in effects {
            effect.on()
        }
        for sampler in samplers {
            sampler.on()
        }
    }
    
    func setFrequency(_ frequency: Double) {
        self.frequency = frequency
    }
    
    public func off() {
        for oscilator in oscilators {
            oscilator.off()
        }
        for effect in effects {
            effect.off()
        }
        for sampler in samplers {
            sampler.off()
        }
    }
    
    var frequency: Double = 0
    public func nextSample() -> Double {
        var processingSample = oscilators.map{$0.waveGenerator.nextSample(frequency: frequency * halfToneToScale($0.tune.value)) * $0.volume.value}.reduce(0, +)
        
        for effect in effects {
            processingSample = effect.apply(input: processingSample)
        }
        
        return processingSample + samplers.map{$0.nextSample()}.reduce(0, +)
    }
}
