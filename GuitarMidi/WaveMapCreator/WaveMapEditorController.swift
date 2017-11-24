//
//  WaveMapEditorController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 24.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit
import NodesMap
import GuitarDsp

class WaveMapEditorController: UIViewController {
    private weak var mapViewController: MapViewController!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    var waveMap: WaveMap!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapController = segue.destination as? MapViewController {
            self.mapViewController = mapController
            updateWaveMap(waveMap)
        }
        if let addNodesController = segue.destination as? NodesListViewController {
            addNodesController.addNode = {
                self.waveMap.startAddingWaveNode($0)
            }
        }
    }
    
    @IBAction func selectAction(_ sender: Any?) {
        waveMap.map.startSelecting()
    }
    
    @IBAction func deleteAction(_ sender: Any?) {
        waveMap.map.startDeleting()
    }
    
    func updateWaveMap(_ waveMap: WaveMap) {
        self.waveMap = waveMap
        mapViewController.updateMap(waveMap.map)
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
            if let foldbackEffect = node.model as? FoldbackWaveEffect {
                let foldbackViewController = UIStoryboard(name: "Foldback", bundle: nil).instantiateInitialViewController() as! FoldbackViewController
                foldbackViewController.foldbackEffect = foldbackEffect
                self?.showController(foldbackViewController)
            }
            if let oscilator = node.model as? Oscilator {
                let oscilatorViewController = OscilatorViewController.make()
                oscilatorViewController.oscilator = oscilator
                self?.showController(oscilatorViewController)
            }
            if let waveShaper = node.model as? WaveShaper {
                let waveShaperViewController = WaveShaperViewController.make()
                waveShaperViewController.waveShaper = waveShaper
                self?.showController(waveShaperViewController)
            }
            if let reverb = node.model as? ReverbWaveEffect {
                let reverbController = ReverbViewController.make()
                reverbController.reverbEffect = reverb
                self?.showController(reverbController)
            }
            if let phaser = node.model as? PhaserWaveEffect {
                let phaserController = PhaserViewController.make()
                phaserController.phaserWaveEffect = phaser
                self?.showController(phaserController)
            }
        }
    }
    
    private func showController(_ controller: UIViewController) {
        present(controller, animated: true, completion: nil)
    }
}
