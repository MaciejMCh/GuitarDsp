//
//  EffectsOrderViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 30.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarDsp

class EffectsOrderViewController: NSViewController {
    @IBOutlet weak var reorderStackView: ReorderStackView!
    var setupOnLoad: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnLoad?()
    }
    
    func setupWithEffects(effects: [Effect]) {
        setupOnLoad = { [weak self] in
            for effect in effects {
                let effectView = EffectIdentityView.make()!
                effectView.effect = effect
                self?.reorderStackView.addView(effectView)
            }
        }
    }
}

class EffectIdentityView: NSView {
    @IBOutlet weak var nameLabel: NSTextField!
    
    var effect: Effect! {
        didSet {
            updateSubviews()
        }
    }
    
    func updateSubviews() {
        nameLabel.stringValue = EffectViewModel(effect: effect).name()
    }
}

class ReorderStackView: NSStackView {
    
    func addView(_ view: NSView) {
        addView(view, in: .top)
        setupDragging(view: view)
    }
    
    func setupDragging(view: NSView) {
        view.addGestureRecognizer(NSPanGestureRecognizer(target: self, action: #selector(handleDrag)))
    }
    
    func handleDrag(dragGesture: NSPanGestureRecognizer) {
        switch dragGesture.state {
        case .began: beginDragging(view: dragGesture.view!)
        case .changed: updateDragging(dragGesture: dragGesture)
        default: break
        }
    }
    
    func beginDragging(view: NSView) {
        lastIndex = views.index(of: view)
    }
    
    func updateDragging(dragGesture: NSPanGestureRecognizer) {
        let gestureLocation = dragGesture.location(in: self)
        
        for view in self.views {
            if view.frame.contains(gestureLocation) {
                let index = views.index(of: view)!
                if index != lastIndex {
                    removeView(view)
                    insertView(view, at: index + (index < lastIndex! ? 1 : -1), in: .top)
                }
                lastIndex = index
                return
            }
        }
    }
    
    var lastIndex: Int?
}
