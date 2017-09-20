//
//  AmpViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class AmpViewController: NSViewController {
    var ampEffect: AmpWaveEffect!
    
    weak var gainViewController: VariableViewController!
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let variableViewController = segue.destinationController as? VariableViewController {
            gainViewController = variableViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gainViewController.setVariable(ampEffect.gain)
        gainViewController.variableUpdate = { [weak self] in
            self?.ampEffect.gain = $0
        }
    }
}
