//
//  SamplingSettingsUtils.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

extension SamplingSettings {
    func samplesInSecond() -> Double {
        return Double(frequency)
    }
}

protocol HasSamplingSettings {
    var samplingSettings: SamplingSettings {get}
}

extension HasSamplingSettings {
    var samplingSettings: SamplingSettings {return AudioInterface.shared().samplingSettings}
}
