//
//  CubicBezier.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 19.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

struct CubicBezier {
    let p1: CGPoint
    let p2: CGPoint
    
    func y(x: Double) -> Double {
        let f1 = 3 * x * pow(1 - x, 2)
        let f2 = 3 * x * x * (1 - x)
        let f3 = x * x * x
        let y = Double(p1.y) * f1 + Double(p2.y) * f2 + f3
        return y
    }
}
