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
    weak var mapEditorViewController: WaveMapEditorController!
    
    var waveMapSource = WaveMapSource.orphan
    var waveMap: WaveMap!
    var mapChange: ((WaveMap) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapEditorViewController = segue.destination as? WaveMapEditorController {
            self.mapEditorViewController = mapEditorViewController
            mapEditorViewController.waveMap = waveMap
        }
    }
    
    @IBAction func songsAction(_ sender: Any?) {
        let songsController = SongsListViewController.make()
        present(songsController, animated: true, completion: nil)
    }
    
    @IBAction func padAction(_ sender: Any?) {
        let padViewController = PadContainerViewController.make()
        let padMidiOutput = PadMidiOutput()
        let previousMidiOutput = waveMap.midiOutput
        padViewController.setup(padMidiOutput: padMidiOutput) { [weak self] in
            self?.waveMap.midiOutput = previousMidiOutput
        }
        waveMap.midiOutput = padMidiOutput
        present(padViewController, animated: true, completion: nil)
    }
    
    @IBAction func newAction(_ sender: Any?) {
        waveMap = WaveMap(samplingSettings: AudioInterface.shared().samplingSettings, midiOutput: Sequencer())
        waveMapSource = .orphan
        mapEditorViewController.updateWaveMap(waveMap)
        mapChange?(waveMap)
    }
    
    @IBAction func loadAction(_ sender: Any?) {
        let controller = UIStoryboard(name: "WaveMapPicker", bundle: nil).instantiateInitialViewController() as! WaveMapPickerController
        controller.pickWaveMap = {[weak self] (waveMap, name) in
            self?.waveMap = waveMap
            self?.waveMapSource = .assigned(name: name)
            self?.mapEditorViewController.updateWaveMap(waveMap)
            self?.mapChange?(waveMap)
        }
        present(controller, animated: true, completion: nil)
    }
    
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
                guard newName.count > 0 else {return}
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
}
