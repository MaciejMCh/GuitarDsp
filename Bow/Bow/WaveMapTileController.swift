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
        waveMapController.creator = WaveNodesFactory(samplingSettings: samplingSettings)
        presentViewControllerAsModalWindow(waveMapController)
    }
}
