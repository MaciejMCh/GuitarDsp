//
//  ChannelPlayerTileViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 27.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarMidi
import GuitarDsp

class WaveMapTileController: NSViewController {
    var waveMap: WaveMap!
    var samplingSettings: SamplingSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    @IBAction func editAction(sender: Any?) {
        let waveMapController = NSStoryboard(name: "WaveMap", bundle: Bundle(identifier: "org.cocoapods.GuitarMidi")!).instantiateInitialController() as! WaveMapController
        waveMapController.waveMap = waveMap
        waveMapController.creator = EffectsFacory(samplingSettings: samplingSettings)
        presentViewControllerAsModalWindow(waveMapController)
    }
}

extension EffectsFacory: SoundNetworkElementsCreator {
    func makeLpf() -> LowpassFilterEffect {
        return LowpassFilterEffect(id: nil)
    }
    
    func makeOscilator() -> Oscilator {
        return makeOscilator(id: nil)
    }
    
    func makeFoldback() -> FoldbackWaveEffect {
        return makeFoldback(id: nil)
    }
    
    func makeAmp() -> AmpWaveEffect {
        return makeAmpWaveEffect(id: nil)
    }
    
    func makeConstant() -> Constant {
        return makeConstant(id: nil)
    }
    
    func makeSampler() -> Sampler {
        return makeSampler(id: nil)
    }
    
    func makeEnvelope() -> EnvelopeFunction {
        return makeEnvelope(id: nil)
    }
    
    func makeSum() -> SumWaveNode {
        return makeSum(id: nil)
    }
    
    func makeWaveShaper() -> WaveShaper {
        return makeWaveShaper(id: nil)
    }
    
    func makeOverdrive() -> OverdriveWaveEffect {
        return makeOverdrive(id: nil)
    }
}
