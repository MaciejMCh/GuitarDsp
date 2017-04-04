//
//  PatternImageView.swift
//  Bow
//
//  Created by Maciej Chmielewski on 04.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

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
