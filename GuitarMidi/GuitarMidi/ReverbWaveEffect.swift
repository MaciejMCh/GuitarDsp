//
//  ReverbWaveEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 21.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

public class ReverbWaveEffect: WaveNode {
    public let id: String
    private let ff = FlipFlop()
    let freeverb = Freeverb()
    
    let input: SignalInput = SignalInput()
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.next(time: $0) ?? 0}}()
    
    public init(id: String? = nil) {
        self.id = id ?? UUID().uuidString
    }
    
    public func next(time: Int) -> Double {
        return ff.value(time: time) {
            var inputValue = Float(self.input.output?.next(time) ?? 0)
            var outputValue: Float = 0
            freeverb.processmix(&inputValue, outputL: &outputValue, numsamples: 1, skip: 1)
            return Double(outputValue)
        }
    }
}
