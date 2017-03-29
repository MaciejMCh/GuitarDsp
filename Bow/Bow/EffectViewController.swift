//
//  EffectViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 28.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarDsp

class EffectViewController: NSViewController {
    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var slidersStackView: NSStackView!
    @IBOutlet weak var nameLabel: NSTextField!
    var effect: Effect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearence()
        setupSliders()
    }
    
    func setupAppearence() {
        nameLabel.stringValue = EffectViewModel(effect: effect).name()
        
        view.wantsLayer = true
        view.layer!.cornerRadius = 10
        backgroundView.layer!.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
    }
    
    func setupSliders() {
        if let reverbEffect = effect as? ReverbEffect {
            for sliderViewController in SlidersFactory().reverb(effect: reverbEffect) {
                addChildViewController(sliderViewController)
                slidersStackView.addView(sliderViewController.view, in: .leading)
            }
        }
    }
}
