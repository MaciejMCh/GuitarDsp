//
//  VariableLabelController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 30.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class VariableLabelController: UIViewController {
    @IBOutlet weak var label: UILabel!
    var initialValue: Double!
    var range: Range<Double>!
    var update: ((Double) -> ())?
    private var state = State.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabel(value: initialValue)
    }
    
    func setup(range: Range<Double>, initial: Double, update: @escaping (Double) -> ()) {
        self.initialValue = initial
        self.range = range
        self.update = update
        currentProgess = (initial - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    
    private func updateLabel(value: Double) {
        label.text = String(format: "%.3f", value)
    }
    
    @IBAction func panAction(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let editorView = makeEditorView()
            UIApplication.shared.keyWindow?.addSubview(editorView)
            state = .editing(editorView: editorView, originLocation: gesture.location(in: nil))
        case .ended, .failed, .cancelled:
            if case .editing(let editorView, _) = state {
                editorView.removeFromSuperview()
                label.textColor = .black
                state = .none
            }
        case .changed:
            if case .editing(let editorView, _) = state {
                label.textColor = .red
                state = .editing(editorView: editorView, originLocation: gesture.location(in: nil))
            }
        default: break
        }
    }
    
    private var editorTouchOrigin: CGPoint = .zero
    private var currentProgess = 0.0
    
    @objc func editorPanAction(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began: editorTouchOrigin = gesture.location(in: nil)
        case .changed:
            guard case .editing(_, let originLocation) = state else {return}
            let part = circlePart(angleOrigin: originLocation, angleFirstOrigin: editorTouchOrigin, angleSecondOrigin: gesture.location(in: nil))
            reportChange(progress: currentProgess + part)
        case .ended, .failed, .cancelled:
            guard case .editing(_, let originLocation) = state else {return}
            let part = circlePart(angleOrigin: originLocation, angleFirstOrigin: editorTouchOrigin, angleSecondOrigin: gesture.location(in: nil))
            currentProgess = max(min(1, currentProgess + part), 0)
            reportChange(progress: currentProgess)
        default: break
        }
    }
    
    private func reportChange(progress: Double) {
        let trimmedProgress = max(min(1, progress), 0)
        let newValue = range.lowerBound + (trimmedProgress * (range.upperBound - range.lowerBound))
        updateLabel(value: newValue)
        update?(newValue)
    }
    
    private func circlePart(angleOrigin: CGPoint, angleFirstOrigin: CGPoint, angleSecondOrigin: CGPoint) -> Double {
        let b = angleOrigin
        let a = angleFirstOrigin
        let c = angleSecondOrigin
        
        let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let cb = CGPoint(x: b.x - c.x, y: b.y - c.y)
        
        let dot = (ab.x * cb.x + ab.y * cb.y)
        let cross = (ab.x * cb.y - ab.y * cb.x)
        
        let alpha = atan2(cross, dot)
        
        return Double(alpha) / Double.pi / 2
    }
    
    private func makeEditorView() -> UIView {
        let editorView = UIView()
        editorView.frame = UIScreen.main.bounds
        editorView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(editorPanAction)))
        return editorView
    }
    
}

extension VariableLabelController {
    enum State {
        case none
        case editing(editorView: UIView, originLocation: CGPoint)
    }
}
