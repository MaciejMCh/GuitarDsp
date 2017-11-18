//
//  GraphView.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 06.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class GraphView: UIView {
    var values: [Double]? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let values = values else {return}
        
        let sortedValues = values.sorted()
        let valueSpaceHeight = sortedValues.last! - sortedValues.first!
        let minValue: Double = sortedValues.first!
        
        let yScale = rect.height / CGFloat(valueSpaceHeight)
        let xScale = rect.width / CGFloat(values.count)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineWidth(1)
        
        context?.move(to: CGPoint(x: 0, y: rect.height))
        
        for i in 0..<values.count {
            context?.addLine(to: CGPoint(x: CGFloat(i) * xScale, y: (CGFloat(values[i] - minValue) * yScale)))
        }
        
        context?.strokePath()
    }
}
