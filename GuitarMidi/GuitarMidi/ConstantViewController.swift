//
//  ConstantViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 10.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class ConstantViewController: NSViewController {
    @IBOutlet weak var variableTextField: VariableTextField!
    var constant: Constant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        variableTextField.stringValue = String(constant.value)
    }
    
    @IBAction func variableTextFieldAction(_ sender: Any?) {
        constant.value = Double()
    }
}
