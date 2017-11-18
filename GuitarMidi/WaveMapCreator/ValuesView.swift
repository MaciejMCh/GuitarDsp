//
//  ValuesViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 18.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class ValuesView: UIView {
    var values: [Double] = [] {
        didSet {
            minValue = values.min()!
            maxValue = values.max()!
            self.setNeedsDisplay()
        }
    }
    
    private var minValue = -1.0
    private var maxValue = 1.0
    
    override func draw(_ rect: CGRect) {
        let dirtyRect = rect
        
        super.draw(dirtyRect)
        
        guard values.count > 1 else {return}
        
        let valueSpaceWidth = values.count
        let valueSpaceHeight = maxValue - minValue
        
        let xScale = bounds.width / CGFloat(valueSpaceWidth)
        let yScale = bounds.height / CGFloat(valueSpaceHeight)
        let skip = Int(0.5 / xScale)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: CGFloat(values.first!) * yScale))
        
        var i: CGFloat = 0
        for value in values {
            defer {
                i += 1
            }
            
            if skip > 1 && Int(i) % skip != 0 {
                continue
            }
            
            let x = i * xScale
            let y = CGFloat(value - minValue) * yScale
            
            if xScale > 5 {
                UIBezierPath(rect: CGRect(x: x - 1, y: y - 1, width: 3, height: 3)).fill()
            }
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.stroke()
    }
}
