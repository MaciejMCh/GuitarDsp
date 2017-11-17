//
//  OscilatorViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 30.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class OscilatorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var waveShapePicker: UIPickerView!
    var oscilator: Oscilator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waveShapePicker.selectRow(WaveShape.all().index(of: oscilator.waveGenerator.waveShape)!, inComponent: 0, animated: false)
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return WaveShape.all().count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        oscilator.waveGenerator.waveShape = WaveShape.all()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch WaveShape.all()[row] {
        case .sine: return "sine"
        case .square: return "square"
        case .triangle: return "triangle"
        case .sawtooth: return "sawtooth"
        case .circle: return "circle"
        }
    }
    
}
