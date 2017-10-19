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
        
        let oscilator = Oscilator(samplingSettings: ss)
        oscilator.setFrequency(1000)
        var values: [Double] = []
        for i in 0..<1000 {
            values.append(oscilator.next(time: i))
        }
        
        let foldback = FoldbackWaveEffect()
        foldback.input.output = oscilator.output
        var values2: [Double] = []
        for i in 0..<1000 {
            values2.append(foldback.next(time: i))
        }
        
        let lpf = LowpassFilterEffect()
        lpf.input.output = foldback.output
        var values3: [Double] = []
        for i in 0..<1000 {
            values3.append(lpf.next(time: i))
        }
        
        let overdrive = OverdriveWaveEffect()
        overdrive.input.output = oscilator.output
        var values4: [Double] = []
        for i in 0..<1000 {
            values4.append(overdrive.next(time: i))
        }
        
        waveView1.values = values2
        waveView2.values = values3
    }
}
