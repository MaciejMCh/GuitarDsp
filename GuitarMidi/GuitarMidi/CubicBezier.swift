//
//  CubicBezier.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 19.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

public struct CubicBezier {
    public let p1: CGPoint
    public let p2: CGPoint
    
    public init(p1: CGPoint, p2: CGPoint) {
        self.p1 = p1
        self.p2 = p2
    }
    
    public func y(x: Double) -> Double {
        let f1 = 3 * x * pow(1 - x, 2)
        let f2 = 3 * x * x * (1 - x)
        let f3 = x * x * x
        let y = Double(p1.y) * f1 + Double(p2.y) * f2 + f3
        return y
    }
}

extension CubicBezier {
    public static let fadeOut = CubicBezier(p1: .init(x: 0, y: 1), p2: .init(x: 0, y: 1))
    public static let fadeIn = CubicBezier(p1: .init(x: 1, y: 0), p2: .init(x: 1, y: 0))
    public static let fadeInOut = CubicBezier(p1: .init(x: 1, y: 0), p2: .init(x: 0, y: 1))
}
