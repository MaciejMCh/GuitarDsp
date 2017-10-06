//
//  WaveEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

public protocol Playing {
    func on()
    func off()
}

extension Playing {
    public func on() {}
    public func off() {}
}

public protocol WaveEffect: Playing {
    func apply(input: Double) -> Double
}

public class AmpWaveEffect {
    public var gain: FunctionVariable = 1.0
    
    let input: SignalInput = SignalInput()
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.next(time: $0) ?? 0}}()
    
    public init() {}
    
    public func next(time: Int) -> Double {
        return input.output?.next(time) ?? 0
    }
    
    public func on() {
        gain.on()
    }
    
    public func off() {
        gain.off()
    }
}
