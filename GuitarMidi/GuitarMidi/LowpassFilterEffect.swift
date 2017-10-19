//
//  LowpassFilterEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 19.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

public class LowpassFilterEffect: WaveNode {
    public let id: String
    public var width: FunctionVariable = Constant(value: 0.2)
    private let ff = FlipFlop()
    private var buffer = 0.0
    
    let input: SignalInput = SignalInput()
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.next(time: $0) ?? 0}}()
    
    public init(id: String? = nil) {
        self.id = id ?? IdGenerator.next()
    }
    
    public func next(time: Int) -> Double {
        return ff.value(time: time) {
            guard let inputValue = self.input.output?.next(time) else {return 0}
            self.buffer = (inputValue * width.next(time: time)) + (self.buffer * (1 - width.next(time: time)))
            return self.buffer
        }
    }
}

