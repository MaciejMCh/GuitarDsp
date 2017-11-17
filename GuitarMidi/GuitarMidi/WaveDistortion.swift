//
//  WaveDistortion.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 28.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

public class OverdriveWaveEffect: WaveNode {
    public let id: String
    public var treshold: FunctionVariable = Constant(value: 0.8)
    private let ff = FlipFlop()
    
    var negative = false
    var compress = false
    
    let input: SignalInput = SignalInput()
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.next(time: $0) ?? 0}}()
    
    public init(id: String? = nil) {
        self.id = id ?? IdGenerator.next()
    }
    
    public func next(time: Int) -> Double {
        return ff.value(time: time) {
            guard let inputValue = self.input.output?.next(time) else {return 0}
            let croppedSample: Double
            if negative {
                croppedSample = min(abs(inputValue), self.treshold.next(time: time)) * sign(inputValue)
            } else {
                croppedSample = min(inputValue, self.treshold.next(time: time))
            }
            return compress ? croppedSample / self.treshold.next(time: time) : croppedSample
        }
    }
}

public class FoldbackWaveEffect: WaveNode {
    public let id: String
    public var treshold: FunctionVariable = Constant(value: 0.8)
    private let ff = FlipFlop()
    
    var negative = false
    var compress = false
    
    let input: SignalInput = SignalInput()
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.next(time: $0) ?? 0}}()
    
    public init(id: String? = nil) {
        self.id = id ?? IdGenerator.next()
    }
    
    public func next(time: Int) -> Double {
        return ff.value(time: time) {
            guard let inputValue = self.input.output?.next(time) else {return 0}
            
            let output: Double
            if negative {
                let diff = abs(inputValue) - self.treshold.next(time: time)
                output = diff > 0 ? inputValue - (2 * diff * sign(inputValue)) : inputValue
            } else {
                let diff = inputValue - self.treshold.next(time: time)
                output = diff > 0 ? inputValue - (2 * diff * inputValue) : inputValue
            }
            
            return compress ? output / self.treshold.next(time: time) : output
        }
    }
}
