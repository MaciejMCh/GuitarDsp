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
    @IBOutlet weak var gridView: GridView!
    
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
        gridView.addView(view: viewToInsert)
        var frame = viewToInsert.frame
        frame.origin.x = CGFloat(index) * CGFloat(300)
        frame.origin.y = 100
        frame.size.height = EffectViewModel.viewHeight
        viewToInsert.frame = frame
    }
}

class GridView: NSView {
    private var views: [NSView] = []
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        let padding = CGFloat(10)
        
        var previousFrame: NSRect?
        for view in views {
            var currentFrame = view.frame
            if let previousFrame = previousFrame {
                if previousFrame.maxX + currentFrame.width + (padding * 2) > frame.width {
                    currentFrame.origin.x = padding
                    currentFrame.origin.y = previousFrame.origin.y - previousFrame.height - padding
                } else {
                    currentFrame.origin.x = previousFrame.maxX + padding
                    currentFrame.origin.y = previousFrame.origin.y
                }
            } else {
                currentFrame.origin.x = padding
                currentFrame.origin.y = frame.height - currentFrame.height - padding
            }
            
            view.frame = currentFrame
            previousFrame = view.frame
        }
    }
    
    func addView(view: NSView) {
        views.append(view)
        addSubview(view)
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
