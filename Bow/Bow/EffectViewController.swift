//
//  EffectViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 28.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class EffectViewController: NSViewController {
    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var slidersStackView: NSStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearence()
        setupSliders()
    }
    
    func setupAppearence() {
        view.wantsLayer = true
        view.layer!.cornerRadius = 10
        backgroundView.layer!.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
    }
    
    func setupSliders() {
        let sliderViewController = SliderViewController.make()
        sliderViewController.configuration = SliderViewController.Configuration(mainColor: NSColor(calibratedRed: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0))
        sliderViewController.setup(valueType: .continous(range: 0.2..<0.8, step: 0.01), currentValue: 0.3)
        sliderViewController.valueChange.subscribe { event in
            print(event)
        }
        slidersStackView.addView(sliderViewController.view, in: .leading)
    }
}
