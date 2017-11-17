//
//  FoldbackViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 17.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class FoldbackViewController: UIViewController {
    @IBOutlet weak var negativesSwitch: UISwitch!
    @IBOutlet weak var compressSwitch: UISwitch!
    
    var foldbackEffect: FoldbackWaveEffect!
    
    @IBAction func switchAction(_ sender: Any?) {
        foldbackEffect.negative = negativesSwitch.isOn
        foldbackEffect.compress = compressSwitch.isOn
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
}
