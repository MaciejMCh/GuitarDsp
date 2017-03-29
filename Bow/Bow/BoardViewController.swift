//
//  BoardViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 28.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarDsp

class BoardViewController: NSViewController {
    var board: Board!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addEffectControllers()
    }
    
    func addEffectControllers() {
        var i = 0
        for effect in board.effects {
            let effectController = EffectViewController.make()
            effectController.effect = effect
            addChildViewController(effectController)
            insertViewInSocket(viewToInsert: effectController.view, index: i)
            i += 1
        }
    }
    
    func insertViewInSocket(viewToInsert: NSView, index: Int) {
        view.addSubview(viewToInsert)
        var frame = viewToInsert.frame
        frame.origin.x = CGFloat(index) * CGFloat(300)
        frame.origin.y = 100
        viewToInsert.frame = frame
    }
}

class PatternImageView: NSView {
    @IBInspectable var patternImage: NSImage?
    
    lazy var patternColor: NSColor = {
        if let patternImage = self.patternImage {
            return NSColor(patternImage: patternImage)
        } else {
            return NSColor.red
        }
    }()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let context = NSGraphicsContext.current()!
        context.saveGraphicsState()
        context.patternPhase = NSPoint(x: 0, y: dirtyRect.height)
        patternColor.set()
        NSRectFill(dirtyRect)
        context.restoreGraphicsState()
    }
}
