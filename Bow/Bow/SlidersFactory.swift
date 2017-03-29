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
