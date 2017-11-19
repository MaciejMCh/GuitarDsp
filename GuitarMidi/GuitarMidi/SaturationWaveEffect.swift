//
//  SaturationWaveEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 19.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

public class SaturationWaveEffect: WaveNode {
    public let id: String
    let input: SignalInput = SignalInput()
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.next(time: $0) ?? 0}}()
    public var level: FunctionVariable = Constant(value: 1)
    private let ff = FlipFlop()
    
    init(id: String? = nil) {
        self.id = id ?? UUID().uuidString
    }
    
    public func next(time: Int) -> Double {
        return ff.value(time: time) {
            let inputValue = (input.output?.next(time) ?? 0) * level.next(time: time)
            return sign(inputValue) * (1 - pow(M_E, -abs(inputValue)))
        }
    }
}
