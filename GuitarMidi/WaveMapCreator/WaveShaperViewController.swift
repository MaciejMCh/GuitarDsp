//
//  WaveShaperViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 17.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class WaveShaperViewController: UIViewController {
    @IBOutlet weak var mirrorNegativesSwitch: UISwitch!
    var waveShaper: WaveShaper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mirrorNegativesSwitch.isOn = waveShaper.mirrorNegatives
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cubicBezierViewController = segue.destination as? CubicBezierViewController {
            cubicBezierViewController.cubicBezier = waveShaper.cubicBezier
            cubicBezierViewController.update = {[weak self] in
                self?.waveShaper.cubicBezier = $0
            }
        }
    }
    
    @IBAction func mirrorNegativesSwitchAction(_ sender: Any?) {
        waveShaper.mirrorNegatives = mirrorNegativesSwitch.isOn
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
}
