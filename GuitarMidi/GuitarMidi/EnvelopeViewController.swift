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
    weak var decayBezierViewController: CubicBezierViewController!
    weak var releaseBezierViewController: CubicBezierViewController!
    
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
        if let bezierViewController = segue.destinationController as? CubicBezierViewController, let identifier = segue.identifier {
            switch identifier {
            case "attackBezier":
                bezierViewController.update = { [weak self] (p1, p2) in
                    self?.envelopeFunction.attackBezier = CubicBezier(p1: p1, p2: p2)
                    self?.envelopeView.needsDisplay = true
                }
                attackBezierViewController = bezierViewController
            case "decayBezier":
                bezierViewController.update = { [weak self] (p1, p2) in
                    self?.envelopeFunction.decayBezier = CubicBezier(p1: p1, p2: p2)
                    self?.envelopeView.needsDisplay = true
                }
                decayBezierViewController = bezierViewController
            case "releaseBezier":
                bezierViewController.update = { [weak self] (p1, p2) in
                    self?.envelopeFunction.releaseBezier = CubicBezier(p1: p1, p2: p2)
                    self?.envelopeView.needsDisplay = true
                }
                releaseBezierViewController = bezierViewController
            default: break
            }
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
        
        NSBezierPath(rect: dirtyRect).stroke()
        
        let length = 400
        let height = 100.0
        let margin = 10.0
        
        let truePath = NSBezierPath()
        truePath.move(to: .init(x: CGFloat(margin), y: CGFloat(margin)))
        
        envelopeFunction.duration = Double(length / 2)
        envelopeFunction.on()
        for i in 0..<length {
            truePath.line(to: .init(x: CGFloat(margin) + CGFloat(i), y: CGFloat(margin) + CGFloat(height) * CGFloat(envelopeFunction.nextSample())))
            if i == length / 2 {
                envelopeFunction.off()
            }
        }
        envelopeFunction.off()
        
        NSColor.red.setStroke()
        truePath.stroke()
    }
    
    private func drawBezier(bezier: CubicBezier, rect: CGRect, inverse: Bool = false) {
        let bezierPath = NSBezierPath()
        bezierPath.move(to: rect.origin)
        let pointsCount = Int(rect.width)
        for i in 0..<pointsCount {
            let x = Double(i) / Double(pointsCount)
            let y = bezier.y(x: x)
            
            if inverse {
                bezierPath.line(to: NSPoint(x: Double(rect.minX) + x * Double(rect.width),
                                            y: (Double(rect.minY) + y * Double(rect.height))))
            } else {
                bezierPath.line(to: NSPoint(x: Double(rect.minX) + x * Double(rect.width),
                                            y: Double(rect.minY) + y * Double(rect.height)))
            }
        }
        NSColor.green.setStroke()
        bezierPath.stroke()
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
