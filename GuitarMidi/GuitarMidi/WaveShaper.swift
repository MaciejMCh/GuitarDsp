//
//  WaveShaper.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 21.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

public class WaveShaper: WaveNode {
    public let id: String
    public var cubicBezier: CubicBezier = CubicBezier(p1: .zero, p2: .zero)
    public var mirrorNegatives: Bool = true
    let ff = FlipFlop()
    
    let input: SignalInput = SignalInput()
    lazy var output: SignalOutput = {SignalOutput(waveName: "waveshaper_\(id)_output") {[weak self] in self?.next(time: $0) ?? 0}}()
    
    public init(id: String? = nil) {
        self.id = id ?? IdGenerator.next()
    }
    
    public func next(time: Int) -> Double {
        return ff.value(time: time) {
            guard let inputValue = self.input.output?.next(time) else {return 0}
            
            if self.mirrorNegatives && inputValue < 0 {
                return -self.cubicBezier.y(x: -inputValue)
            } else {
                return self.cubicBezier.y(x: inputValue)
            }
        }
    }
}
