//
//  WaveShaperViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 21.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import CubicBezierPicker

class WaveShaperViewController: NSViewController {
    @IBOutlet weak var waveView: WaveView!
    weak var cubicBezierViewController: CubicBezierViewController!
    
    var waveShaper: WaveShaper!
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let cubicBezierViewController = segue.destinationController as? CubicBezierViewController {
            self.cubicBezierViewController = cubicBezierViewController
            cubicBezierViewController.update = { [weak self] in
                self?.updateBezier(bezier: CubicBezier(p1: $0, p2: $1))
            }
        }
    }
    
    private func updateBezier(bezier: CubicBezier) {
        waveShaper.cubicBezier = bezier
        
        let valuesCount = 1000
        var values: [Double] = []
        for i in 0..<valuesCount {
            let x: Double = Double(i) / Double(valuesCount)
            let sinY = sin(x * Double.pi * 4)
            values.append(waveShaper.apply(input: sinY))
        }
        waveView.values = values
    }
}


class WaveView: NSView {
    var values: [Double] = [] {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard values.count > 1 else {return}
        
        let valueSpaceWidth = values.count
        let minValue = values.min()!
        let valueSpaceHeight = values.max()! - minValue
        
        let xScale = bounds.width / CGFloat(valueSpaceWidth)
        let yScale = bounds.height / CGFloat(valueSpaceHeight)
        
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 0, y: CGFloat(values.first!) * yScale))
        
        var i: CGFloat = 0
        for value in values {
            let x = i * xScale
            let y = CGFloat(value - minValue) * yScale
            
            if xScale > 5 {
                NSBezierPath(rect: NSRect(x: x - 1, y: y - 1, width: 3, height: 3)).fill()
            }
            
            path.line(to: NSPoint(x: x, y: y))
            i += 1
        }
        
        path.stroke()
    }
}
