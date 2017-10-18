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
        nameLabel.stringValue = EffectViewModel(effect: effectPrototype.instance).name()
        
        view.wantsLayer = true
        view.layer!.cornerRadius = 10
        backgroundView.layer!.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
    }
    
    func setupSliders() {
        let sliders = sliderViewControllers()
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
    
    func sliderViewControllers() -> [SliderViewController] {
        let color = EffectViewModel(effect: effectPrototype.instance).color()
        switch effectPrototype.instance {
        case .amp(let effect): return SlidersFactory().amp(amp: effect, color: color)
        case .bitCrusher(let effect): return SlidersFactory().bitCrusher(bitCrusher: effect, color: color)
        case .compressor(let effect): return SlidersFactory().compressor(compressor: effect, color: color)
        case .delay(let effect): return SlidersFactory().delay(delay: effect, color: color)
        case .flanger(let effect): return SlidersFactory().flanger(flangerEffect: effect, color: color)
        case .harmonizer(let effect): return SlidersFactory().harmonizer(harmonizer: effect, color: color)
        case .phaseVocoder(let effect): return SlidersFactory().phaseVocoder(phaseVocoder: effect, color: color)
        case .reverb(let effect): return SlidersFactory().reverb(effect: effect, color: color)
        case .vibe(let effect): return SlidersFactory().vibe(vibeEffect: effect, color: color)
        case .phaser(let effect): return SlidersFactory().phaser(phaserEffect: effect, color: color)
        case .distortion(let effect): return SlidersFactory().distortion(distortionEffect: effect, color: color)
        case .waveMap: return "" as! [SliderViewController]
        }
    }
}
