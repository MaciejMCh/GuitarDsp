//
//  TimeFunctionViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class TimeFunctionViewController: NSTabViewController {
    var functionChange: ((FunctionVariable) -> ())?
    var initialFunctionVariable: FunctionVariable!
    
    override func viewDidLoad() {
        for controller in tabViewItems.map({$0.viewController}) {
            (controller as? EnvelopeViewController)?.envelopeFunction = initialFunctionVariable as? EnvelopeFunction ?? EnvelopeFunction()
        }
        super.viewDidLoad()
    }
    
    
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        if let envelopeController = tabViewItem?.viewController as? EnvelopeViewController {
            functionChange?(envelopeController.envelopeFunction)
        }
    }
}
