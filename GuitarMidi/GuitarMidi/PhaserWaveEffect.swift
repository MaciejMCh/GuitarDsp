//
//  PhaserWaveEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 21.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

class PhaserWaveEffect: WaveNode {
    public let id: String
    private let samplingSettings: SamplingSettings
    private let ff = FlipFlop()
    let phaserEffect: PhaserEffect
    
    let input: SignalInput = SignalInput()
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.next(time: $0) ?? 0}}()
    
    public init(samplingSettings: SamplingSettings, id: String? = nil) {
        self.samplingSettings = samplingSettings
        self.id = id ?? UUID().uuidString
        phaserEffect = PhaserEffect(samplingSettings: samplingSettings)
    }
    
    func next(time: Int) -> Double {
        return ff.value(time: time) {
            let inputValue = Float(self.input.output?.next(time) ?? 0)
            return Double(phaserEffect.update(inputValue))
        }
    }
}
