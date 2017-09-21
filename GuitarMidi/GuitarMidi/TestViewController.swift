//
//  TestViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 21.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarDsp

class TestViewController: NSViewController {
    @IBOutlet weak var waveView1: WaveView!
    @IBOutlet weak var waveView2: WaveView!
    
    override func viewDidLoad() {
        let osc1 = Oscilator(samplingSettings: AudioInterface.shared().samplingSettings)
        osc1.waveGenerator.waveShape = .sine
        
        let osc2 = Oscilator(samplingSettings: AudioInterface.shared().samplingSettings)
        osc2.waveGenerator.waveShape = .circle
        
        let valuesCount = 1000
        let frequency = 2.0
        
        var values1: [Double] = [-1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1]
        var values2: [Double] = [-1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1]
        for _ in 0..<valuesCount {
            values1.append(osc1.waveGenerator.nextSample(frequency: frequency))
            values2.append(osc2.waveGenerator.nextSample(frequency: frequency))
        }
        
        waveView1.values = values1
        waveView2.values = values2
    }
}
