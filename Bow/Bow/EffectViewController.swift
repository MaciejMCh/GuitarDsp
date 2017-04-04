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
    var effectPrototype: EffectPrototype!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearence()
        setupSliders()
    }
    
    func setupAppearence() {
        nameLabel.stringValue = EffectViewModel(effect: effectPrototype).name()
        
        view.wantsLayer = true
        view.layer!.cornerRadius = 10
        backgroundView.layer!.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
    }
    
    func setupSliders() {
        let sliders = sliderViewControllers(effect: effectPrototype.effect)
        for sliderViewController in sliders {
            addChildViewController(sliderViewController)
            slidersStackView.addView(sliderViewController.view, in: .leading)
            var frame = sliderViewController.view.frame
            frame.size.width = SliderViewModel().sliderWidth
            sliderViewController.view.frame = frame
        }
        
        var frame = view.frame
        frame.size.width = CGFloat(sliders.count) * SliderViewModel().sliderWidth
        view.frame = frame
    }
    
    func sliderViewControllers(effect: Effect) -> [SliderViewController] {
        let color = EffectViewModel(effect: effectPrototype).color()
        if let reverbEffect = effect as? ReverbEffect {
            return SlidersFactory().reverb(effect: reverbEffect, color: color)
        }
        if let harmonizerEffect = effect as? HarmonizerEffect {
            return SlidersFactory().harmonizer(harmonizer: harmonizerEffect, color: color)
        }
        if let phaseVocoderEffect = effect as? PhaseVocoderEffect {
            return SlidersFactory().phaseVocoder(phaseVocoder: phaseVocoderEffect, color: color)
        }
        if let delayEffect = effect as? DelayEffect {
            return SlidersFactory().delay(delay: delayEffect, color: color)
        }
        if let ampEffect = effect as? AmpEffect {
            return SlidersFactory().amp(amp: ampEffect, color: color)
        }
        assert(false)
        return []
    }
}
