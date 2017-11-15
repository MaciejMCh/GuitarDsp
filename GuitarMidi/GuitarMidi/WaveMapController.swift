//
//  WaveMapController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 06.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import NodesMap
import GuitarDsp

public class WaveMapController: NSViewController {
    weak var mapViewController: MapViewController!
    public var creator: WaveNodesFactory!
    public var waveMap: WaveMap!
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destinationController as? MapViewController {
            mapViewController.map = waveMap.map
            self.mapViewController = mapViewController
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        waveMap.map.select = { node in
            if let oscilator = node.model as? Oscilator {
                let oscilatorController = OscilatorViewController.make()
                oscilatorController.oscilator = oscilator
                self.presentViewControllerAsModalWindow(oscilatorController)
            }
            if let envelope = node.model as? EnvelopeFunction {
                let envelopeViewController = EnvelopeViewController.make()
                envelopeViewController.envelopeFunction = envelope
                self.presentViewControllerAsModalWindow(envelopeViewController)
            }
            if let sampler = node.model as? Sampler {
                let samplerViewController = NSStoryboard(name: "Sampler", bundle: Bundle(identifier: "org.cocoapods.GuitarMidi")!).instantiateInitialController() as! SamplerViewController
                samplerViewController.sampler = sampler
                self.presentViewControllerAsModalWindow(samplerViewController)
            }
            if let waveShaper = node.model as? WaveShaper {
                let waveShaperViewController = NSStoryboard(name: "WaveShaper", bundle: Bundle(identifier: "org.cocoapods.GuitarMidi")!).instantiateInitialController() as! WaveShaperViewController
                waveShaperViewController.waveShaper = waveShaper
                self.presentViewControllerAsModalWindow(waveShaperViewController)
            }
            if let constant = node.model as? Constant {
                let constantViewController = ConstantViewController.make()
                constantViewController.constant = constant
                self.presentViewControllerAsModalWindow(constantViewController)
            }
        }
    }
    
    @IBAction func newOscilator(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeOscilator())
    }
    
    @IBAction func newSampler(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeSampler())
    }
    
    @IBAction func newEnvelope(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeEnvelope())
    }
    
    @IBAction func newConstant(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeConstant())
    }
    
    @IBAction func newAmp(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeAmpWaveEffect())
    }
    
    @IBAction func newSum(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeSum())
    }
    
    @IBAction func newWaveShaper(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeWaveShaper())
    }
    
    @IBAction func newOverdrive(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeOverdrive())
    }
    
    @IBAction func newFoldback(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeFoldback())
    }
    
    @IBAction func newLpf(_ sender: Any?) {
        waveMap.addWaveNode(waveNode: creator.makeLpf())
    }
}
