//
//  CubicBezierViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 31.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func adding(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: x + point.x, y: y + point.y)
    }
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        return CGFloat(sqrt(pow(x - point.x, 2) + pow(y - point.y, 2)))
    }
    
    func closest(points: [CGPoint]) -> CGPoint? {
        return points.map{($0, $0.distanceTo(self))}.sorted{$0.1 < $1.1}.first?.0
    }
    
    func isSame(_ point: CGPoint) -> Bool {
        return x == point.x && y == point.y
    }
}

class CubicBezierViewController: UIViewController {
    @IBOutlet weak var cubicBezierView: CubicBezierView!
    @IBOutlet weak var p1View: UIView!
    @IBOutlet weak var p2View: UIView!
    var cubicBezier: CubicBezier!
    var update: ((CubicBezier) -> ())?
    
    private let dotSize = 40.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cubicBezierView.cubicBezier = cubicBezier
        
        p1View.layer.cornerRadius = CGFloat(dotSize / 2)
        p2View.layer.cornerRadius = CGFloat(dotSize / 2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDotViewsPositions()
    }
    
    private func updateDotViewsPositions() {
        p1View.frame = CGRect(origin: cubicBezierView.convertPointToViewSpace(cubicBezier.p1).adding(CGPoint(x: -dotSize / 2, y: -dotSize / 2)),
                              size: CGSize(width: dotSize, height: dotSize))
        p2View.frame = CGRect(origin: cubicBezierView.convertPointToViewSpace(cubicBezier.p2).adding(CGPoint(x: -dotSize / 2, y: -dotSize / 2)),
                              size: CGSize(width: dotSize, height: dotSize))
    }
    
    @IBAction func dotPanAction(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .changed else {return}
    
        if gesture.view == p1View {
            cubicBezier = CubicBezier(p1: cubicBezierView.convertPointToBezierSpace(gesture.location(in: view)),
                                      p2: cubicBezier.p2)
        }
        if gesture.view == p2View {
            cubicBezier = CubicBezier(p1: cubicBezier.p1,
                                      p2: cubicBezierView.convertPointToBezierSpace(gesture.location(in: view)))
        }
        
        updateDotViewsPositions()
        cubicBezierView.cubicBezier = cubicBezier
        update?(cubicBezier)
    }
}

class CubicBezierView: UIView {
    var cubicBezier: CubicBezier! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineWidth(2)
        
        context?.move(to: CGPoint(x: 0, y: rect.height))
        context?.addLine(to: convertPointToViewSpace(cubicBezier.p1))
        
        context?.move(to: CGPoint(x: rect.width, y: 0))
        context?.addLine(to: convertPointToViewSpace(cubicBezier.p2))
        
        context?.strokePath()
        
        
        context?.setStrokeColor(UIColor.blue.cgColor)
        context?.setLineWidth(2)
        
        context?.move(to: CGPoint(x: 0, y: rect.height))
        let numberOfpoints = 50
        for i in 0..<numberOfpoints {
            let bezierX = Double(Double(i) / Double(numberOfpoints))
            let bezierY = cubicBezier.y(x: bezierX)
            context?.addLine(to: convertPointToViewSpace(CGPoint(x: bezierX, y: bezierY)))
        }
        
        context?.strokePath()
    }
    
    func convertPointToViewSpace(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x * frame.width, y: (1 - point.y) * frame.height)
    }
    
    func convertPointToBezierSpace(_ point: CGPoint) -> CGPoint {
        let x = point.x / frame.width
        let y = 1 - (point.y / frame.height)
        return CGPoint(x: max(0, min(1, x)), y: max(0, min(1, y)))
    }
}
