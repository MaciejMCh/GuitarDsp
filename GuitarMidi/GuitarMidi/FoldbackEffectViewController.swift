//
//  FoldbackEffectViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 28.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class FoldbackViewController: NSViewController {
    var foldbackEffect: FoldbackWaveEffect!
    
    weak var tresholdViewController: VariableViewController!
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let variableViewController = segue.destinationController as? VariableViewController {
            tresholdViewController = variableViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tresholdViewController.setVariable(foldbackEffect.treshold)
        tresholdViewController.variableUpdate = { [weak self] in
            self?.foldbackEffect.treshold = $0
        }
    }
}
