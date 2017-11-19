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
        let ss = AudioInterface.shared().samplingSettings
        
        let signalLength = 1000
        
        let oscilator = Oscilator(samplingSettings: ss)
        oscilator.setFrequency(1000)
        var rawValues: [Double] = []
        for i in 0..<signalLength {
            rawValues.append(oscilator.next(time: i))
        }
        
        let foldback = FoldbackWaveEffect()
        foldback.input.output = oscilator.output
        var foldbackValues: [Double] = []
        for i in 0..<signalLength {
            foldbackValues.append(foldback.next(time: i))
        }
        
        let lpf = LowpassFilterEffect()
        lpf.input.output = foldback.output
        var lpfValues: [Double] = []
        for i in 0..<signalLength {
            lpfValues.append(lpf.next(time: i))
        }
        
        let overdrive = OverdriveWaveEffect()
        overdrive.negative = false
        overdrive.compress = false
        overdrive.input.output = oscilator.output
        var overdireValues: [Double] = []
        for i in 0..<signalLength {
            overdireValues.append(overdrive.next(time: i))
        }
        
        let saturation = SaturationWaveEffect()
        saturation.input.output = oscilator.output
        var saturationValues: [Double] = []
        for i in 0..<signalLength {
            saturationValues.append(saturation.next(time: i))
        }
        
        waveView1.values = rawValues
        waveView2.values = saturationValues
    }
}
