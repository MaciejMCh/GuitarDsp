//
//  SignalGenerator.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 12.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

enum SignalGenerator {
    case sine(amplitude: Float, frequency: Float)
    case ramp(slope: Float)
    case input
}
