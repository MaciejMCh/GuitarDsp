//
//  WaveEffectControllers.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 20.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

struct WaveEffectControllers {
    static func make(waveEffect: WaveEffect) -> NSViewController {
        if let ampEffect = waveEffect as? AmpWaveEffect {
            let ampController = AmpViewController.make()
            ampController.ampEffect = ampEffect
            return ampController
        }
        
        if let waveShaper = waveEffect as? WaveShaper {
            let waveShaperController = WaveShaperNodeViewController.make()
            waveShaperController.waveShaper = waveShaper
            return waveShaperController
        }
        
        if let foldback = waveEffect as? FoldbackWaveEffect {
            let foldbackViewController = FoldbackViewController.make()
            foldbackViewController.foldbackEffect = foldback
            return foldbackViewController
        }
        
        return "" as! NSViewController
    }
}
