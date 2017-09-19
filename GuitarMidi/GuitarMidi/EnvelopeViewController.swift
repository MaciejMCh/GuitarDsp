//
//  EnvelopeViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 19.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import CubicBezierPicker

class EnvelopeViewController: NSViewController {
    @IBOutlet weak var envelopeView: EnvelopeView!
    @IBOutlet weak var delayTextField: NSTextField!
    @IBOutlet weak var attackTextField: NSTextField!
    @IBOutlet weak var holdTextField: NSTextField!
    @IBOutlet weak var decayTextField: NSTextField!
    @IBOutlet weak var sustainTextField: NSTextField!
    @IBOutlet weak var releaseTextField: NSTextField!
    weak var attackBezierViewController: CubicBezierViewController!
    
    let envelopeFunction = EnvelopeFunction()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        envelopeView.envelopeFunction = envelopeFunction
        updateViews()
    }
    
    private func updateViews() {
        delayTextField.stringValue = String(envelopeFunction.delay)
        attackTextField.stringValue = String(envelopeFunction.attack)
        holdTextField.stringValue = String(envelopeFunction.hold)
        decayTextField.stringValue = String(envelopeFunction.decay)
        sustainTextField.stringValue = String(envelopeFunction.sustain)
        releaseTextField.stringValue = String(envelopeFunction.release)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let cubicBezierViewController = segue.destinationController as? CubicBezierViewController {
            self.attackBezierViewController = cubicBezierViewController
        }
    }
    
    @IBAction func textFieldChanged(_ sender: Any?) {
        envelopeFunction.delay = Double(delayTextField.stringValue) ?? 0
        envelopeFunction.attack = Double(attackTextField.stringValue) ?? 0
        envelopeFunction.hold = Double(holdTextField.stringValue) ?? 0
        envelopeFunction.decay = Double(decayTextField.stringValue) ?? 0
        envelopeFunction.sustain = Double(sustainTextField.stringValue) ?? 0
        envelopeFunction.release = Double(releaseTextField.stringValue) ?? 0
        
        envelopeView.needsDisplay = true
    }
}

class EnvelopeView: NSView {
    var envelopeFunction: EnvelopeFunction!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSBezierPath.init(rect: dirtyRect).stroke()
        
        let maxY = 100.0
        let maxX = 200.0
        let minX = 10.0
        let minY = 10.0
        
        let path = NSBezierPath()
        
        var x = minX
        var y = minY
        
        let controlPointSize = 5.0
        let controlPointColor = NSColor.blue
        
        x += envelopeFunction.delay * maxX
        path.move(to: CGPoint(x: x, y: y))
        circle(x: x, y: y, size: controlPointSize, color: controlPointColor)
        
        x += envelopeFunction.attack * maxX
        y = maxY
        path.line(to: CGPoint(x: x, y: y))
        circle(x: x, y: y, size: controlPointSize, color: controlPointColor)
        
        x += envelopeFunction.hold * maxX
        path.line(to: CGPoint(x: x, y: y))
        circle(x: x, y: y, size: controlPointSize, color: controlPointColor)
        
        x += envelopeFunction.decay * maxX
        y = envelopeFunction.sustain * maxY
        path.line(to: CGPoint(x: x, y: y))
        circle(x: x, y: y, size: controlPointSize, color: controlPointColor)
        
        x += envelopeFunction.release * maxX
        y = minY
        path.line(to: CGPoint(x: x, y: y))
        circle(x: x, y: y, size: controlPointSize, color: controlPointColor)
        
        path.stroke()
    }
    
    private func circle(x: Double, y: Double, size: Double, color: NSColor) {
        let rect = NSRect(x: CGFloat(x) - CGFloat(size) / 2, y: CGFloat(y) - CGFloat(size) / 2, width: CGFloat(size), height: CGFloat(size))
        let circlePath = NSBezierPath()
        circlePath.appendOval(in: rect)
        NSColor.black.setStroke()
        color.setFill()
        circlePath.stroke()
        circlePath.fill()
    }
}
