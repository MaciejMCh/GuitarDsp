//
//  ReverbViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 21.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class ReverbViewController: UIViewController {
    var reverbEffect: ReverbWaveEffect!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let variableViewController = segue.destination as? VariableLabelController, let segueId = segue.identifier {
            let freeverb = reverbEffect.freeverb
            switch segueId {
            case "roomSize": variableViewController.setup(range: 0..<1, initial: Double(freeverb.getroomsize())) {freeverb.setroomsize(Float($0))}
            case "damp": variableViewController.setup(range: 0..<1, initial: Double(freeverb.getdamp())) {freeverb.setdamp(Float($0))}
            default: assert(false)
            }
        }
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
}
