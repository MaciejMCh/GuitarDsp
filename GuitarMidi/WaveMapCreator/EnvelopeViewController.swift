//
//  EnvelopeViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 31.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit
import GuitarDsp

class EnvelopeViewController: UIViewController {
    var envelopeFunction: EnvelopeFunction!
    @IBOutlet weak var envelopeGraphView: GraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateGraph()
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let variableLabelController = segue.destination as? VariableLabelController, let segueId = segue.identifier {
            switch segueId {
            case "delay": variableLabelController.setup(range: 0..<1, initial: envelopeFunction.delay) {self.envelopeFunction.delay = $0; self.updateGraph()}
            case "attack": variableLabelController.setup(range: 0..<1, initial: envelopeFunction.attack) {self.envelopeFunction.attack = $0; self.updateGraph()}
            case "hold": variableLabelController.setup(range: 0..<1, initial: envelopeFunction.hold) {self.envelopeFunction.hold = $0; self.updateGraph()}
            case "decay": variableLabelController.setup(range: 0..<1, initial: envelopeFunction.decay) {self.envelopeFunction.decay = $0; self.updateGraph()}
            case "sustain": variableLabelController.setup(range: 0..<1, initial: envelopeFunction.sustain) {self.envelopeFunction.sustain = $0; self.updateGraph()}
            case "release": variableLabelController.setup(range: 0..<1, initial: envelopeFunction.release) {self.envelopeFunction.release = $0; self.updateGraph()}
            case "volume": variableLabelController.setup(range: 0..<1, initial: envelopeFunction.volume) {self.envelopeFunction.volume = $0; self.updateGraph()}
            default: assert(false)
            }
        }
        if let cubicBezierController = segue.destination as? CubicBezierViewController, let segueId = segue.identifier {
            switch segueId {
            case "attack":
                cubicBezierController.cubicBezier = envelopeFunction.attackBezier ?? .none
                cubicBezierController.update = {self.envelopeFunction.attackBezier = $0; self.updateGraph()}
            case "decay":
                cubicBezierController.cubicBezier = envelopeFunction.decayBezier ?? .none
                cubicBezierController.update = {self.envelopeFunction.decayBezier = $0; self.updateGraph()}
            case "release":
                cubicBezierController.cubicBezier = envelopeFunction.releaseBezier ?? .none
                cubicBezierController.update = {self.envelopeFunction.releaseBezier = $0; self.updateGraph()}
            default: assert(false)
            }
        }
    }
    
    private func updateGraph() {
        let length = 10000
        let drawingEnvelope = envelopeFunction.makeClone()
        drawingEnvelope.duration = Double(length / 2)
        drawingEnvelope.on()
        var values: [Double] = []
        for i in 0..<length {
            values.append(drawingEnvelope.next(time: i))
            if i == Int((drawingEnvelope.delay + drawingEnvelope.attack + drawingEnvelope.hold + drawingEnvelope.decay + 0.1) * drawingEnvelope.duration) {
                drawingEnvelope.off()
            }
        }
        envelopeGraphView.values = values
    }
}
