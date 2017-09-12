//
//  ViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 05.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var midiServer: MidiServer? = MidiServer()
    
    @IBAction func stop(sender: Any?) {
        midiServer = nil
    }
    
}

