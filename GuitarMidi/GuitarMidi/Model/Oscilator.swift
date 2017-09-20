//
//  Oscilator.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

class Oscilator: Playing {
    var waveGenerator = WaveGenerator()
    var tune: FunctionVariable = -12
    var volume: FunctionVariable = 1
    
    func on() {
        tune.on()
    }
    
    func off() {
        tune.off()
    }
}
