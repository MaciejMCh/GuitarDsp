//
//  WaveShaperNodeViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 21.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class WaveShaperNodeViewController: NSViewController {
    var waveShaper: WaveShaper!
    
    @IBAction func editAction(sender: Any?) {
        let waveShaperViewController = WaveShaperViewController.make()
        waveShaperViewController.waveShaper = waveShaper
        presentViewControllerAsModalWindow(waveShaperViewController)
    }
}
