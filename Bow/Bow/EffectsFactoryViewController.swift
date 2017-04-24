//
//  EffectsFactoryViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 30.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarDsp

class EffectsFacoryViewController: NSViewController {
    var effectsFactory: EffectsFacory! {
        didSet {
            allEffects = effectsFactory.all().map{EffectPrototype(effect: $0)}
        }
    }
    private var allEffects: [EffectPrototype]!
    @IBOutlet var stackView: NSStackView!
    
    var addEffectCallback: ((EffectPrototype) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        var frame = view.frame
        frame.size.height = EffectsFactoryViewModel().tileSize
        frame.size.width = EffectsFactoryViewModel().tileSize * CGFloat(allEffects.count)
        view.frame = frame
        
        for effect in allEffects {
            let button = NSButton(frame: NSRect(x: 0, y: 0, width: EffectsFactoryViewModel().tileSize, height: EffectsFactoryViewModel().tileSize))
            button.title = "\n\n\n\(EffectViewModel(effect: effect.instance).name())\n\n\n"
            button.font = NSFont(name: "Courier-Bold", size: 15)
            button.wantsLayer = true
            button.isBordered = false
            button.layer?.backgroundColor = EffectViewModel(effect: effect.instance).color().withAlphaComponent(0.3).cgColor
            button.target = self
            button.action = #selector(buttonAction)
            stackView.addView(button, in: .leading)
        }
    }
    
    func buttonAction(button: NSButton) {
        addEffectCallback?(allEffects[stackView.views.index(of: button)!])
        dismissViewController(self)
    }
}
