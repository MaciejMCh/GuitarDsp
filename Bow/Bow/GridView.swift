//
//  GridView.swift
//  Bow
//
//  Created by Maciej Chmielewski on 04.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class GridView: NSView {
    private var views: [NSView] = []
    
    override func layout() {
        super.layout()
        resizeSubviews(withOldSize: bounds.size)
    }
    
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
    
    func clear() {
        for view in views {
            view.removeFromSuperview()
        }
        views = []
    }
    
}
