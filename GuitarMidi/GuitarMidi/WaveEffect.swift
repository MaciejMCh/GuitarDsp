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

public class AmpWaveEffect: WaveEffect {
    public var gain: FunctionVariable = 1.0
    
    public init() {}
    
    public func apply(input: Double) -> Double {
        return input * gain.value
    }
    
    public func on() {
        gain.on()
    }
    
    public func off() {
        gain.off()
    }
}
