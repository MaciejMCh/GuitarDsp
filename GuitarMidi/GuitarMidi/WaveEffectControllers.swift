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
        
        return "" as! NSViewController
    }
}
