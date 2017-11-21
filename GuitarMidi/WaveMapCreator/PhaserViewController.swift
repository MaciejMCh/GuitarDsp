//
//  PhaserViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 21.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class PhaserViewController: UIViewController {
    var phaserWaveEffect: PhaserWaveEffect!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let phaserEffect = phaserWaveEffect.phaserEffect
        
        if let variableVC = segue.destination as? VariableLabelController, let segueId = segue.identifier {
            switch segueId {
            case "fmin": variableVC.setup(range: 100..<2000, initial: Double(phaserEffect.rangeFmin)) {phaserEffect.updateRangeFmin(min(Float($0), phaserEffect.rangeFmax), fMax: phaserEffect.rangeFmax)}
            case "fmax": variableVC.setup(range: 100..<2000, initial: Double(phaserEffect.rangeFmax)) {phaserEffect.updateRangeFmin(phaserEffect.rangeFmin, fMax: max(Float($0), phaserEffect.rangeFmin))}
            case "depth": variableVC.setup(range: 0..<1, initial: Double(phaserEffect.depth)) {phaserEffect.updateDepth(Float($0))}
            case "feedback": variableVC.setup(range: 0..<1, initial: Double(phaserEffect.feedback)) {phaserEffect.updateFeedback(Float($0))}
            case "rate": variableVC.setup(range: 0..<5, initial: Double(phaserEffect.rate)) {phaserEffect.updateRate(Float($0))}
            default: assert(false)
            }
        }
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
}
