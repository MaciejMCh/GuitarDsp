//
//  Bass808ViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

var bass808xD = Bass808()

class Bass808ViewController: NSViewController {
    @IBOutlet weak var effectsStackView: NSStackView!
    @IBOutlet weak var oscilatorsStackView: NSStackView!
    private var oscilatorViewControllers: [OscilatorViewController] = []
    private var effectViewControllers: [NSViewController] = []
    
    private var bass808: Bass808 {
        return bass808xD
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshView()
    }
    
    @IBAction func addOscilator(sender: Any?) {
        bass808.oscilators.append(Oscilator())
        refreshView()
    }
    
    private func refreshView() {
        for oscilatorViewController in oscilatorViewControllers {
            oscilatorsStackView.removeView(oscilatorViewController.view)
        }
        oscilatorViewControllers.removeAll()
        
        for oscilator in bass808.oscilators {
            let oscilatorViewController = OscilatorViewController.make()
            oscilatorViewController.oscilator = oscilator
            
            oscilatorViewControllers.append(oscilatorViewController)
            oscilatorsStackView.insertView(oscilatorViewController.view, at: 0, in: .leading)
        }
        
        for effectViewController in effectViewControllers {
            effectsStackView.removeView(effectViewController.view)
        }
        effectViewControllers.removeAll()
        
        for effect in bass808.effects {
            let effectViewController = WaveEffectControllers.make(waveEffect: effect)
            
            effectViewControllers.append(effectViewController)
            effectsStackView.insertView(effectViewController.view, at: 0, in: .center)
        }
    }
}

class PlayerView: NSView {
    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
        layer?.backgroundColor = NSColor.blue.cgColor
        becomeFirstResponder()
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        bass808xD.on()
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        bass808xD.off()
    }
}
