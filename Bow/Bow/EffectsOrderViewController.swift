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
import RxSwift

class EffectsOrderViewController: NSViewController {
    @IBOutlet weak var reorderStackView: ReorderStackView!
    private var setupOnLoad: (() -> ())?
    private var structureChanged: (() -> ())?
    
    var effectsFactory: EffectsFacory!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnLoad?()
        reorderStackView.structureChanged = structureChanged
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let effectsFactoryViewController = segue.destinationController as? EffectsFacoryViewController {
            effectsFactoryViewController.effectsFactory = self.effectsFactory
            effectsFactoryViewController.addEffectCallback = { [weak self] in
                self?.addEffect(effect: $0)
            }
        }
    }
    
    func setupWithEffects(effects: [Effect]) {
        setupOnLoad = { [weak self] in
            guard let wSelf = self else {return}
            for effect in effects {
                let effectView = wSelf.makeEffectView(effect: effect)
                wSelf.reorderStackView.addView(effectView)
            }
        }
    }
    
    func makeEffectView(effect: Effect) -> EffectIdentityView {
        let effectView = EffectIdentityView.make()!
        effectView.effect = effect
        effectView.removeButton.target = self
        effectView.removeButton.action = #selector(removeButtonAction)
        return effectView
    }
    
    func addEffect(effect: Effect) {
        let effectView = makeEffectView(effect: effect)
        reorderStackView.addView(effectView)
        structureChanged?()
    }
    
    func removeButtonAction(button: NSButton) {
        reorderStackView.removeView(button.superview!)
        structureChanged?()
    }
    
    lazy var structureChange: Observable<[Effect]> = {
        return Observable.create { [weak self] observer in
            let cancel = Disposables.create {
                
            }
            self?.structureChanged = {
                guard let wSelf = self else {return}
                observer.on(.next(wSelf.effects()))
            }
            
            return cancel
        }
    }()
    
    private func effects() -> [Effect] {
        return (reorderStackView.views as! [EffectIdentityView]).map{$0.effect}
    }
    
}

class EffectIdentityView: NSView {
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var removeButton: NSButton!
    
    var effect: Effect! {
        didSet {
            updateSubviews()
        }
    }
    
    func updateSubviews() {
        nameLabel.stringValue = EffectViewModel(effect: effect).name()
        wantsLayer = true
        layer?.backgroundColor = EffectViewModel(effect: effect).color().withAlphaComponent(0.2).cgColor
    }
}

class ReorderStackView: NSStackView {
    var structureChanged: (() -> ())?
    
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
                    structureChanged?()
                }
                lastIndex = index
                return
            }
        }
    }
    
    var lastIndex: Int?
}
