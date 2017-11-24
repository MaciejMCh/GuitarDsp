//
//  WaveMapSyncEditor.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 24.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit
import GuitarDsp

extension WaveMapSyncViewController {
    struct Setup {
        let waveMapReference: WaveMapReference
        let samplingSettings: SamplingSettings
    }
}

class WaveMapSyncViewController: UIViewController {
    private var waveMap: WaveMap!
    private var setup: Setup!
    private var timer: Timer?
    private var lastSentConfiguration: [String: Any]?
    
    func setup(_ setup: Setup) {
        self.setup = setup
        let waveMap = WaveMap(samplingSettings: setup.samplingSettings, midiOutput: nil)
        WaveMapStorage.configureWaveMap(waveMap, configuration: setup.waveMapReference.configuration)
        self.waveMap = waveMap
    }
    
    @IBAction func close(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.sync()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    private func sync() {
        let configuration = WaveMapStorage.waveMapConfiguration(waveMap)
        if let lastSentConfiguration = lastSentConfiguration {
            if NSDictionary(dictionary: lastSentConfiguration).isEqual(to: configuration) {
                return
            }
        }
        lastSentConfiguration = configuration
        WaveMapSyncClient().sync(reference: WaveMapReference(name: setup.waveMapReference.name, configuration: configuration))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let waveMapEditor = segue.destination as? WaveMapEditorController {
            waveMapEditor.waveMap = waveMap
        }
    }
}
