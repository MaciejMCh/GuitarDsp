//
//  ScrollDetectingView.swift
//  Bow
//
//  Created by Maciej Chmielewski on 29.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class ScrollDetectingView: NSView {
    private var state: State = .inactive
    var reportScroll: ((CGPoint) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        acceptsTouchEvents = true
        wantsRestingTouches = true
    }
    
    override func touchesBegan(with event: NSEvent) {
        let onTouches = Array(event.touches(matching: .touching, in: self))
        if (onTouches.count == 2) {
            state = .scrolling(lastPoint: touchingPoint(touches: onTouches))
        }
    }
    
    override func touchesEnded(with event: NSEvent) {
        state = .inactive
    }
    
    override func touchesCancelled(with event: NSEvent) {
        state = .inactive
    }
    
    override func touchesMoved(with event: NSEvent) {
        switch state {
        case .scrolling(let lastPoint):
            let newPoint = touchingPoint(touches: Array(event.touches(matching: .touching, in: self)))
            reportScroll?(newPoint - lastPoint)
            state = .scrolling(lastPoint: newPoint)
        default: break
        }
    }
    
    private func touchingPoint(touches: [NSTouch]) -> CGPoint {
        return touches.map{$0.normalizedPosition}.reduce(CGPoint.zero, +).scaledBy(scalar: 1.0 / Float(touches.count))
    }
}

extension ScrollDetectingView {
    enum State {
        case inactive
        case scrolling(lastPoint: CGPoint)
    }
}

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    func scaledBy(scalar: Float) -> CGPoint {
        return CGPoint(x: x * CGFloat(scalar), y: y * CGFloat(scalar))
    }
}
