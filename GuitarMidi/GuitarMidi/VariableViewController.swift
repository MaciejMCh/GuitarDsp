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
    
    private var initialVariable: FunctionVariable!
    var variableUpdate: ((FunctionVariable) -> ())?
    
    func setVariable(_ variable: FunctionVariable) {
        initialVariable = variable
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
    
    @IBAction func functionButtonAction(_ sencer: Any?) {
        let timeFunctionController = TimeFunctionViewController.make()
        timeFunctionController.initialFunctionVariable = initialVariable
        timeFunctionController.functionChange = { [weak self] in
            self?.variableUpdate?($0)
        }
        presentViewControllerAsModalWindow(timeFunctionController)
    }
    
    private func updateVariable() {
        switch fixedButton.state {
        case 1: variableUpdate?(Constant(value: Double(fixedTextField.stringValue) ?? 0))
        case 0: break
        default: break
        }
    }
}

public class VariableTextField: NSTextField {
    @IBInspectable var minValue: Double = 0
    @IBInspectable var maxValue: Double = 5
    
    enum State {
        case idle
        case dragging(from: CGPoint)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        acceptsTouchEvents = true
    }
    
    public override func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)
    }
    
    public override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        let currentDouble = Double(stringValue)!
        let change = Double(event.deltaY) * -0.01
        
        let newDouble = max(minValue, min(maxValue, currentDouble + change))
        stringValue = String(newDouble)
        target?.perform(action, with: self)
    }
}
