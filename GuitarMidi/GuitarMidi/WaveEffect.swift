//
//  WaveEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import NodesMap

class IdGenerator {
    private static var last: Int = 0
    static func next() -> String {
        defer {
            last += 1
        }
        return String(last)
    }
}

class FlipFlop {
    private var lastValue = 0.0
    private var lastTime = -1
    
    func value(time: Int, value: () -> Double) -> Double {
        if lastTime == time {
            return lastValue
        }
        
        lastTime = time
        lastValue = value()
        return lastValue
    }
}

public protocol WaveNode: MidiPlayer, Indentificable {
    func next(time: Int) -> Double
}

public protocol Playing {
    func on()
    func off()
}

extension Playing {
    public func on() {}
    public func off() {}
}

public class AmpWaveEffect: WaveNode {
    public let id: String
    public var gain: FunctionVariable = Constant(value: 1.0)
    private let ff = FlipFlop()
    
    let input: SignalInput = SignalInput()
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.next(time: $0) ?? 0}}()
    
    public init(id: String? = nil) {
        self.id = id ?? IdGenerator.next()
    }
    
    public func next(time: Int) -> Double {
        return ff.value(time: time) {
            (input.output?.next(time) ?? 0) * self.gain.next(time: time)
        }
    }
    
    public func on() {
        gain.on()
    }
    
    public func off() {
        gain.off()
    }
}

public class SumWaveNode: WaveNode {
    class InputsCollection {
        var outputs: [SignalOutput] = []
    }
    
    public let id: String
    
    let inputCollection = InputsCollection()
    lazy var output: SignalOutput = {SignalOutput {[weak self] in self?.next(time: $0) ?? 0}}()
    
    private let ff = FlipFlop()
    
    public init(id: String? = nil) {
        self.id = id ?? IdGenerator.next()
    }
    
    public func next(time: Int) -> Double {
        return ff.value(time: time) {
            return inputCollection.outputs.map{$0.next(time)}.reduce(0, +)
        }
    }
}
