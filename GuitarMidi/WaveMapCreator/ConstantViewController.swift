//
//  Constant.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 30.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class ConstantViewController: UIViewController {
    var constantVariable: Constant!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let variableLabelController = segue.destination as? VariableLabelController {
            variableLabelController.setup(range: 0..<10, initial: constantVariable.value) { [weak self] in
                self?.constantVariable.value = $0
            }
        }
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}
