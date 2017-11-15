//
//  MapCreatorViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 22.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit
import NodesMap
import GuitarDsp

enum WaveMapSource {
    case orphan
    case assigned(name: String)
}

class MapCreatorViewController: UIViewController {
    var waveMapSource = WaveMapSource.orphan
    
    var waveMap: WaveMap!
    var padMidiOutput: PadMidiOutput!
    
    @IBAction func saveAction(_ sender: Any?) {
        let save: (String, JsonObject) -> Void = { (name, configuration) in
            FirebaseClient().saveWaveMap(name: name, configuration: configuration)
        }
        
        let waveMapConfiguration = WaveMapStorage.waveMapConfiguration(waveMap)
        switch waveMapSource {
        case .orphan:
            let alert = UIAlertController(title: "Save", message: "Name", preferredStyle: UIAlertControllerStyle.alert)
            var textFieldReference: UITextField!
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {[weak self] (action) in
                let newName: String = textFieldReference.text!
                save(newName, waveMapConfiguration)
                self?.waveMapSource = .assigned(name: newName)
            }))
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Name"
                textFieldReference = textField
            })
            present(alert, animated: true, completion: nil)
        case .assigned(let name): save(name, waveMapConfiguration)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waveMap.map.select = { [weak self] node in
            if let constant = node.model as? Constant {
                let constantViewController = UIStoryboard(name: "Constant", bundle: nil).instantiateInitialViewController() as! ConstantViewController
                constantViewController.constantVariable = constant
                self?.showController(constantViewController)
            }
            if let envelopeFunction = node.model as? EnvelopeFunction {
                let envelopeViewController = UIStoryboard(name: "Envelope", bundle: nil).instantiateInitialViewController() as! EnvelopeViewController
                envelopeViewController.envelopeFunction = envelopeFunction
                self?.showController(envelopeViewController)
            }
            if let sampler = node.model as? Sampler {
                let samplerViewController = UIStoryboard(name: "Sampler", bundle: nil).instantiateInitialViewController() as! SamplerViewController
                samplerViewController.sampler = sampler
                self?.showController(samplerViewController)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapController = segue.destination as? MapViewController {
            mapController.map = waveMap.map
        }
        if let addNodesController = segue.destination as? NodesListViewController {
            addNodesController.addNode = {
                self.waveMap.addWaveNode(waveNode: $0)
            }
        }
        if let padController = segue.destination as? PadViewController {
            padController.padMidiOutput = padMidiOutput
        }
    }
    
    private func showController(_ controller: UIViewController) {
        present(controller, animated: true, completion: nil)
    }
}
