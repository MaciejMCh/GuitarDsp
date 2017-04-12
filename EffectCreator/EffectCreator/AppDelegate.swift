//
//  AppDelegate.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 09.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Cocoa
import GuitarDsp

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let length = 100
        var dry: [Float] = Array(repeating: 0.5, count: length)
        var wet: [Float] = Array(repeating: -0.5, count: length)
        
        WavWriter(samplingSettings: AudioInterface.shared().samplingSettings).write(dry: &dry, wet: &wet, length: length)
        
        let processor = Processor(samplingSettings: AudioInterface.shared().samplingSettings, tempo: 120)
        let board = Board()
        board.effects = [makeDevelopmentEffect()]
        processor.activeBoard = board
        AudioInterface.shared().use(processor)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    func makeDevelopmentEffect() -> Effect {
        return WoEffect(samplingSettings: AudioInterface.shared().samplingSettings)
    }

}

