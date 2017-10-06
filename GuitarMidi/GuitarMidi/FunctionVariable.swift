//
//  FunctionVariable.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

typealias FunctionVariableSetter = (FunctionVariable) -> Void

public protocol FunctionVariable: Playing {
    var value: Double {get}
}

extension Double: FunctionVariable {
    public var value: Double {return self}
    public var output: SignalOutput {
        return SignalOutput {_ in self}
    }
}

class LinearFunction: FunctionVariable {
    private let from: Double
    private let to: Double
    private let duration: Int
    private var timeAlive = 0
    
    init(from: Double, to: Double, duration: Int) {
        self.from = from
        self.to = to
        self.duration = duration
    }
    
    var value: Double {
        let progress = min(1, Double(timeAlive) / Double(duration))
        timeAlive += 1
        
        return from + ((to - from) * progress)
    }
}

class FadeOutFunction: FunctionVariable {
    private let from: Double
    private let to: Double
    private let duration: Int
    private var timeAlive = 0
    
    init(from: Double, to: Double, duration: Int) {
        self.from = from
        self.to = to
        self.duration = duration
    }
    
    var value: Double {
        let linearProgress = min(1, Double(timeAlive) / Double(duration))
        timeAlive += 1
        
        let progress = sin(Double.pi * linearProgress * 0.5)
        return from + ((to - from) * progress)
    }
}

class FadeInOutFunction: FunctionVariable {
    private let from: Double
    private let to: Double
    private let duration: Int
    private var timeAlive = 0
    
    init(from: Double, to: Double, duration: Int) {
        self.from = from
        self.to = to
        self.duration = duration
    }
    
    var value: Double {
        let linearProgress = min(1, Double(timeAlive) / Double(duration))
        timeAlive += 1
        
        let progress = (sin((linearProgress + 1.5) * Double.pi) + 1) * 0.5
        
        return from + ((to - from) * progress)
    }
}
