//
//  VariableViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class VariableViewController: NSViewController {
    @IBOutlet weak var fixedButton: NSButton!
    @IBOutlet weak var funcButton: NSButton!
    @IBOutlet weak var editButton: NSButton!
    @IBOutlet weak var fixedTextField: NSTextField!
    
    var variableUpdate: ((FunctionVariable) -> ())?
    
    func setVariable(_ variable: FunctionVariable) {
        if let double = variable as? Double {
            fixedButton.state = 1
            fixedTextField.stringValue = String(double)
            fixedTextField.isEnabled = true
            editButton.isEnabled = false
        }
    }
    
    @IBAction func radioButtonAction(radioButton: NSButton) {
        switch radioButton {
        case fixedButton:
            fixedTextField.isEnabled = true
            editButton.isEnabled = false
        case funcButton:
            editButton.isEnabled = true
            fixedTextField.isEnabled = false
        default: break
        }
        updateVariable()
    }
    
    @IBAction func fixedTextFieldAction(_ sender: Any?) {
        updateVariable()
    }
    
    private func updateVariable() {
        switch fixedButton.state {
        case 1: variableUpdate?(Double(fixedTextField.stringValue)!)
        case 0: break
        default: break
        }
    }
}
