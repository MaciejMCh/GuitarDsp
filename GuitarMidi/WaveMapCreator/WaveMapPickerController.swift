//
//  WaveMapPickerController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 15.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit
import GuitarDsp

class WaveMapPickerController: UIViewController {
    var pickWaveMap: ((WaveMap, String) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let treeViewController = segue.destination as? TreeViewController {
            treeViewController.tree = FileBrowser(root: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/wave_maps", extensions: ["wav"], selectAction: { [weak self] file in
                self?.pickFile(path: file.path)
                }, pickAction: { [weak self] file in
                    self?.pickFile(path: file.path)
                }, selectDirectory: {_ in}).makeTree()
        }
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    private func pickFile(path: String) {
        let configuration = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! JsonObject
        let waveMap = WaveMap(samplingSettings: AudioInterface.shared().samplingSettings, midiOutput: Sequencer())
        WaveMapStorage.configureWaveMap(waveMap, configuration: configuration)
        pickWaveMap?(waveMap, path.components(separatedBy: "/").last!)
    }
}
