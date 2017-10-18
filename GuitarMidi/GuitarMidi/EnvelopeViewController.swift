//
//  EnvelopeViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 19.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import CubicBezier

class EnvelopeViewController: NSViewController, HasSamplingSettings {
    @IBOutlet weak var envelopeView: EnvelopeView!
    @IBOutlet weak var delayTextField: NSTextField!
    @IBOutlet weak var attackTextField: NSTextField!
    @IBOutlet weak var holdTextField: NSTextField!
    @IBOutlet weak var decayTextField: NSTextField!
    @IBOutlet weak var sustainTextField: NSTextField!
    @IBOutlet weak var releaseTextField: NSTextField!
    @IBOutlet weak var volumeTextField: NSTextField!
    @IBOutlet weak var attackBezierSwitchButton: NSButton!
    @IBOutlet weak var decayBezierSwitchButton: NSButton!
    @IBOutlet weak var releaseBezierSwitchButton: NSButton!
    
    private weak var attackBezierViewController: CubicBezierViewController!
    private weak var decayBezierViewController: CubicBezierViewController!
    private weak var releaseBezierViewController: CubicBezierViewController!
    
    var envelopeFunction: EnvelopeFunction!
    var envelopeUpdate: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        envelopeView.envelopeFunction = envelopeFunction
    }
    
    private func updateViews() {
        delayTextField.stringValue = String(envelopeFunction.delay)
        attackTextField.stringValue = String(envelopeFunction.attack)
        holdTextField.stringValue = String(envelopeFunction.hold)
        decayTextField.stringValue = String(envelopeFunction.decay)
        sustainTextField.stringValue = String(envelopeFunction.sustain)
        releaseTextField.stringValue = String(envelopeFunction.release)
        volumeTextField.stringValue = String(envelopeFunction.volume)
        
        attackBezierSwitchButton.state = envelopeFunction.attackBezier == nil ? 0 : 1
        decayBezierSwitchButton.state = envelopeFunction.decayBezier == nil ? 0 : 1
        releaseBezierSwitchButton.state = envelopeFunction.releaseBezier == nil ? 0 : 1
        
        let fadedAlpha = CGFloat(0.1)
        attackBezierViewController.view.alphaValue = envelopeFunction.attackBezier == nil ? fadedAlpha : 1
        decayBezierViewController.view.alphaValue = envelopeFunction.decayBezier == nil ? fadedAlpha : 1
        releaseBezierViewController.view.alphaValue = envelopeFunction.releaseBezier == nil ? fadedAlpha : 1
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateViews()
        
        if let attackBezier = envelopeFunction.attackBezier {
            attackBezierViewController.setup(attackBezier.p1, p2: attackBezier.p2)
        }
        if let decayBezier = envelopeFunction.decayBezier {
            decayBezierViewController.setup(decayBezier.p1, p2: decayBezier.p2)
        }
        if let releaseBezier = envelopeFunction.releaseBezier {
            releaseBezierViewController.setup(releaseBezier.p1, p2: releaseBezier.p2)
        }
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let bezierViewController = segue.destinationController as? CubicBezierViewController, let identifier = segue.identifier {
            switch identifier {
            case "attackBezier":
                bezierViewController.update = { [weak self] (p1, p2) in
                    guard self?.envelopeFunction.attackBezier != nil else {return}
                    self?.envelopeFunction.attackBezier = CubicBezier(p1: p1, p2: p2)
                    self?.envelopeView.needsDisplay = true
                    self?.envelopeUpdate?()
                }
                attackBezierViewController = bezierViewController
            case "decayBezier":
                bezierViewController.update = { [weak self] (p1, p2) in
                    guard self?.envelopeFunction.decayBezier != nil else {return}
                    self?.envelopeFunction.decayBezier = CubicBezier(p1: p1, p2: p2)
                    self?.envelopeView.needsDisplay = true
                    self?.envelopeUpdate?()
                }
                decayBezierViewController = bezierViewController
            case "releaseBezier":
                bezierViewController.update = { [weak self] (p1, p2) in
                    guard self?.envelopeFunction.releaseBezier != nil else {return}
                    self?.envelopeFunction.releaseBezier = CubicBezier(p1: p1, p2: p2)
                    self?.envelopeView.needsDisplay = true
                    self?.envelopeUpdate?()
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
        envelopeFunction.volume =  Double(volumeTextField.stringValue) ?? 0
        
        envelopeView.needsDisplay = true
        envelopeUpdate?()
    }
    
    @IBAction func bezierSwitchChanged(_ sender: NSButton) {
        switch (sender, sender.state) {
        case (attackBezierSwitchButton, let state):
            envelopeFunction.attackBezier = state == 1 ? CubicBezier(p1: attackBezierViewController.bezierDataPoint1, p2: attackBezierViewController.bezierDataPoint2) : nil
        case (decayBezierSwitchButton, let state):
            envelopeFunction.decayBezier = state == 1 ? CubicBezier(p1: decayBezierViewController.bezierDataPoint1, p2: decayBezierViewController.bezierDataPoint2) : nil
        case (releaseBezierSwitchButton, let state):
            envelopeFunction.releaseBezier = state == 1 ? CubicBezier(p1: releaseBezierViewController.bezierDataPoint1, p2: releaseBezierViewController.bezierDataPoint2) : nil
        default: break
        }
        
        updateViews()
        envelopeView.needsDisplay = true
        envelopeUpdate?()
    }
}

class EnvelopeView: NSView {
    var envelopeFunction: EnvelopeFunction!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSBezierPath(rect: dirtyRect).stroke()
        
        let margin = CGFloat(10.0)
        let length = Int(frame.width - (2 * margin))
        let height = frame.height - (2 * margin)
        
        let truePath = NSBezierPath()
        truePath.move(to: .init(x: CGFloat(margin), y: CGFloat(margin)))
        
        let drawingEnvelopeFunction = envelopeFunction.makeClone()
        
        drawingEnvelopeFunction.duration = Double(length / 2)
        drawingEnvelopeFunction.on()
        for i in 0..<length {
            truePath.line(to: .init(x: CGFloat(margin) + CGFloat(i), y: CGFloat(margin) + CGFloat(height) * CGFloat(drawingEnvelopeFunction.next(time: i))))
            if i == length / 2 {
                drawingEnvelopeFunction.off()
            }
        }
        
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

extension EnvelopeFunction {
    func makeClone() -> EnvelopeFunction {
        let cloneEnvelopeFunction = EnvelopeFunction()
        cloneEnvelopeFunction.hold = hold
        cloneEnvelopeFunction.decay = decay
        cloneEnvelopeFunction.delay = delay
        cloneEnvelopeFunction.volume = volume
        cloneEnvelopeFunction.attack = attack
        cloneEnvelopeFunction.sustain = sustain
        cloneEnvelopeFunction.release = release
        cloneEnvelopeFunction.duration = duration
        cloneEnvelopeFunction.decayBezier = decayBezier
        cloneEnvelopeFunction.attackBezier = attackBezier
        cloneEnvelopeFunction.releaseBezier = releaseBezier
        return cloneEnvelopeFunction
    }
}
