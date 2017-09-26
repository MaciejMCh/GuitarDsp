//
//  ViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 05.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBAction func stop(sender: Any?) {
        
    }
    
    @IBAction func lagChanged(textField: NSTextField) {
        guard let int = Int(textField.stringValue) else {return}
        strokeDetectorXd.lag = int
    }
    
    @IBAction func tresholdChanged(textField: NSTextField) {
        guard let double = Double(textField.stringValue) else {return}
        strokeDetectorXd.threshold = double
    }
    
    @IBAction func influenceChanged(textField: NSTextField) {
        guard let double = Double(textField.stringValue) else {return}
        strokeDetectorXd.influence = double
    }
}

