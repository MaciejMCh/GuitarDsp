//
//  PlotView.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 12.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class PlotView: NSView {
    var timeWindow: Range<Int> = 0..<1000
    var values: [Float]! {
        didSet {
            let sorted = values.sorted()
            minValue = sorted.first!
            maxValue = sorted.last!
        }
    }
    
    let leadingMargin = CGFloat(30)
    
    private var maxValue: Float!
    private var minValue: Float!
    
    override func draw(_ dirtyRect: NSRect) {
        let visibleValues = values[timeWindow]
        
        let pointsCount = timeWindow.count
        
        let dX = (dirtyRect.width - leadingMargin) / CGFloat(pointsCount)
        
        let valueHeight = maxValue - minValue
        let scale = dirtyRect.height / CGFloat(valueHeight)
        
        var x = leadingMargin
        
        let myPath = NSBezierPath()
        myPath.move(to: CGPoint(x: x, y: CGFloat(visibleValues.first! - minValue) * scale))
        for value in visibleValues {
            myPath.line(to: CGPoint(x: x, y: CGFloat(value - minValue) * scale))
            x += dX
        }
        
        myPath.stroke()
        
    }
}
