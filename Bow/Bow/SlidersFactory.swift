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
    func reverb(effect: ReverbEffect) -> [SliderViewController] {
        let color = EffectViewModel(effect: effect).color()
        
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
    
    func harmonizer(harmonizer: HarmonizerEffect) -> [SliderViewController] {
        let color = EffectViewModel(effect: harmonizer).color()
        
        var result = phaseShift(color: color, initialValue: harmonizer.shift) {
            harmonizer.shift = $0
        }
        let volume = make(color: color, name: "volume", valueType: .continous(range: 0.0..<1.5, step: 0.01), initialValue: harmonizer.volume) {
            harmonizer.volume = $0
        }
        
        result.append(volume)
        return result
    }
    
    func phaseVocoder(phaseVocoder: PhaseVocoderEffect) -> [SliderViewController] {
        return phaseShift(color: EffectViewModel(effect: phaseVocoder).color(), initialValue: phaseVocoder.shift) {
            phaseVocoder.shift = $0
        }
    }
    
    func delay(delay: DelayEffect) -> [SliderViewController] {
        let color = EffectViewModel(effect: delay).color()
        
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
    
    func amp(amp: AmpEffect) -> [SliderViewController] {
        let color = EffectViewModel(effect: amp).color()
        
        let linear = make(color: color, name: "linear", valueType: .continous(range: 0.0..<10.0, step: 0.05), initialValue: amp.gain) {
            amp.gain = $0
        }
        
        return [linear]
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
            setter(shiftToSemitones($0))
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
