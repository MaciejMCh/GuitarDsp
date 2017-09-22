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
        let sampler = Sampler2(fileName: "kick", fileExtension: "wav")
        waveView1.values = sampler.buffer.map{Double($0)}
//        waveView2.values = values2
    }
}
