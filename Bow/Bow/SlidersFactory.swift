//
//  SlidersFactory.swift
//  Bow
//
//  Created by Maciej Chmielewski on 29.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

struct SlidersFactory {
    func reverb(effect: ReverbEffect, color: NSColor) -> [SliderViewController] {
        let roomSize = make(color: color, name: "room size", valueType: .continous(range: 0.1..<0.9, step: 0.01), initialValue: effect.rev.getroomsize()) {
            effect.rev.setroomsize($0)
        }
        let damp = make(color: color, name: "damp", valueType: .continous(range: 0.0..<1.0, step: 0.01), initialValue: effect.rev.getdamp()) {
            effect.rev.setdamp($0)
        }
        let dry = make(color: color, name: "dry", valueType: .continous(range: 0.0..<1.0, step: 0.01), initialValue: effect.rev.getdry()) {
            effect.rev.setdry($0)
        }
        let wet = make(color: color, name: "wet", valueType: .continous(range: 0.0..<1.0, step: 0.01), initialValue: effect.rev.getwet()) {
            effect.rev.setwet($0)
        }
        let width = make(color: color, name: "width", valueType: .continous(range: 0.0..<1.0, step: 0.01), initialValue: effect.rev.getwidth()) {
            effect.rev.setwidth($0)
        }
        
        return [roomSize, damp, dry, wet, width]
    }
    
    func harmonizer(harmonizer: HarmonizerEffect, color: NSColor) -> [SliderViewController] {
        var result = phaseShift(color: color, initialValue: harmonizer.shift) {
            harmonizer.shift = $0
        }
        let volume = make(color: color, name: "volume", valueType: .continous(range: 0.0..<1.5, step: 0.01), initialValue: harmonizer.volume) {
            harmonizer.volume = $0
        }
        
        result.append(volume)
        return result
    }
    
    func phaseVocoder(phaseVocoder: PhaseVocoderEffect, color: NSColor) -> [SliderViewController] {
        return phaseShift(color: color, initialValue: phaseVocoder.shift) {
            phaseVocoder.shift = $0
        }
    }
    
    func delay(delay: DelayEffect, color: NSColor) -> [SliderViewController] {
        let echoesCount = make(color: color, name: "echoes count", valueType: .continous(range: 1.0..<10.0, step: 1.0), initialValue: Float(delay.echoesCount)) {
            delay.updateEchoesCount(Int32($0))
        }
        let tactPart = make(color: color, name: "tact part", valueType: .discrete(values: [1.0, 2.0, 4.0, 8.0, 16.0]), initialValue: Float(delay.timing.tactPart.rawValue)) {
            delay.updateTact(TactPart(rawValue: UInt($0))!)
        }
        let functionA = make(color: color, name: "fading(a)", valueType: .continous(range: 0.0..<1.0, step: 0.01), initialValue: delay.fadingFunctionA) {
            delay.fadingFunctionA = $0
        }
        let functionB = make(color: color, name: "fading(b)", valueType: .continous(range: 0.0..<1.0, step: 0.01), initialValue: delay.fadingFunctionB) {
            delay.fadingFunctionB = $0
        }
        
        return [echoesCount, functionA, tactPart, functionB]
    }
    
    func amp(amp: AmpEffect, color: NSColor) -> [SliderViewController] {
        let linear = make(color: color, name: "linear", valueType: .continous(range: 0.0..<10.0, step: 0.05), initialValue: amp.gain) {
            amp.gain = $0
        }
        
        return [linear]
    }
    
    func compressor(compressor: CompressorEffect, color: NSColor) -> [SliderViewController] {
        let fadeLevel = make(color: color, name: "fading level", valueType: .continous(range: 1.0..<30.0, step: 1.0), initialValue: compressor.fadingLevel) { [weak compressor] in
            compressor?.fadingLevel = $0
        }
        let noiseLevel = make(color: color, name: "noise level", valueType: .continous(range: 1.0..<30.0, step: 1.0), initialValue: compressor.noiseLevel) { [weak compressor] in
            compressor?.noiseLevel = $0
        }
        return [fadeLevel, noiseLevel]
    }
    
    func bitCrusher(bitCrusher: BitCrusherEffect, color: NSColor) -> [SliderViewController] {
        let samplingReduction = make(color: color, name: "sampling reduction", valueType: .continous(range: 1.0..<64.0, step: 1.0), initialValue: bitCrusher.samplingReduction) { [weak bitCrusher] in
            bitCrusher?.samplingReduction = $0
        }
        let wet = make(color: color, name: "wet", valueType: .continous(range: 0.0..<1.0, step: 0.01), initialValue: bitCrusher.wet) { [weak bitCrusher] in
            bitCrusher?.wet = $0
        }
        let dry = make(color: color, name: "dry", valueType: .continous(range: 0.0..<1.0, step: 0.01), initialValue: bitCrusher.dry) { [weak bitCrusher] in
            bitCrusher?.dry = $0
        }
        return [samplingReduction, wet, dry]
    }
    
    func vibe(vibeEffect: VibeEffect, color: NSColor) -> [SliderViewController] {
        let frequency = make(color: color, name: "frequency", valueType: .exponential(range: -5..<100, exponent: 1.05), initialValue: vibeEffect.frequency) { [weak vibeEffect] in
            vibeEffect?.frequency = $0
        }
        let depth = make(color: color, name: "depth", valueType: .continous(range: 1.0..<300.0, step: 1.0), initialValue: vibeEffect.depth) { [weak vibeEffect] in
            vibeEffect?.depth = $0
        }
        return [frequency, depth]
    }
    
    func flanger(flangerEffect: FlangerEffect, color: NSColor) -> [SliderViewController] {
        let frequency = make(color: color, name: "frequency", valueType: .exponential(range: -5..<100, exponent: 1.05), initialValue: flangerEffect.frequency) { [weak flangerEffect] in
            flangerEffect?.frequency = $0
        }
        let depth = make(color: color, name: "depth", valueType: .continous(range: 0..<1, step: 0.01), initialValue: flangerEffect.depth) { [weak flangerEffect] in
            flangerEffect?.depth = $0
        }
        return [frequency, depth]
    }
    
    func phaser(phaserEffect: PhaserEffect, color: NSColor) -> [SliderViewController] {
        return []
//        let rate = make(color: color, name: "rate", valueType: .continous(range: 0.1..<10, step: 0.01), initialValue: phaserEffect.rate) { [weak phaserEffect] in
//            phaserEffect?.rate = $0
//        }
//        let fMin = make(color: color, name: "f min", valueType: .continous(range: 200..<2000, step: 50), initialValue: phaserEffect.fMin) { [weak phaserEffect] in
//            phaserEffect?.fMin = $0
//        }
//        let fMax = make(color: color, name: "f max", valueType: .continous(range: 200..<2000, step: 50), initialValue: phaserEffect.fMax) { [weak phaserEffect] in
//            phaserEffect?.fMax = $0
//        }
//        return [rate, fMin, fMax]
    }
    
    func distortion(distortionEffect: DistortionEffect, color: NSColor) -> [SliderViewController] {
        let treshold = make(color: color, name: "treshold", valueType: .continous(range: 0.0001..<0.1, step: 0.0001), initialValue: distortionEffect.treshold) { [weak distortionEffect] in
            distortionEffect?.treshold = $0
        }
        
        let level = make(color: color, name: "level", valueType: .continous(range: 0.01..<10.0, step: 0.1), initialValue: distortionEffect.treshold) { [weak distortionEffect] in
            distortionEffect?.level = $0
        }
        return [treshold, level]
    }
    
    private func phaseShift(color: NSColor, initialValue: Float, setter: @escaping (Float) -> Void) -> [SliderViewController] {
        let shiftToSemitones = { (shift: Float) -> Float in
            return log2(shift) * 12.0
        }
        let semitonesToShift = { (semitones: Float) -> Float in
            return pow(2, semitones / 12.0)
        }
        
        let shift = make(color: color, name: "shift", valueType: .discrete(values: [0.25, 0.5, 1.0, 2.0, 4.0]), initialValue: initialValue, update: setter)
        let semitone = make(color: color, name: "semitone", valueType: .continous(range: -12.0..<12.0, step: 1.0), initialValue: shiftToSemitones(initialValue)) {
            setter(semitonesToShift($0))
        }
        return [shift, semitone]
    }
    
    private func make(color: NSColor, name: String, valueType: SliderViewController.ValueType, initialValue: Float, update: @escaping (Float) -> Void) -> SliderViewController {
        let sliderViewController = SliderViewController.make()
        sliderViewController.configuration = SliderViewController.Configuration(mainColor: color, valueName: name)
        sliderViewController.setup(valueType: valueType, currentValue: initialValue)
        sliderViewController.valueChange.subscribe { event in
            switch event {
            case .next(let element): update(element)
            default: break
            }
        }
        return sliderViewController
    }
}
