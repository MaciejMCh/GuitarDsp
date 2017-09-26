//
//  WaveShaper.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 21.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

class WaveShaper: WaveEffect {
    var cubicBezier: CubicBezier = CubicBezier(p1: .zero, p2: .zero)
    var mirrorNegatives: Bool = true
    
    func apply(input: Double) -> Double {
        if mirrorNegatives && input < 0 {
            return -cubicBezier.y(x: -input)
        } else {
            return cubicBezier.y(x: input)
        }
    }
}
