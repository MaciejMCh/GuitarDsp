//
//  OverdriveViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 17.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class OverdriveViewController: UIViewController {
    @IBOutlet weak var negativesSwitch: UISwitch!
    @IBOutlet weak var compressSwitch: UISwitch!
    
    var overdriveEffect: OverdriveWaveEffect!
    
    @IBAction func switchAction(_ sender: Any?) {
        overdriveEffect.negative = negativesSwitch.isOn
        overdriveEffect.compress = compressSwitch.isOn
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
}
