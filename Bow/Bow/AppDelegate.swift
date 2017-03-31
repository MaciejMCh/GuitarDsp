//
//  AppDelegate.swift
//  Bow
//
//  Created by Maciej Chmielewski on 28.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Cocoa
import GuitarDsp

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared().windows.first!.contentViewController = initialController()
    }
    
    func initialController() -> NSViewController {
        let samplingSettings = AudioInterface.shared().samplingSettings
        let processor = Processor(samplingSettings: samplingSettings, tempo: 120)
        AudioInterface.shared().use(processor)
        let board = Board()
        board.effects = []
        processor.activeBoard = board
        let boardViewController = BoardViewController.make()
        boardViewController.board = board
        boardViewController.effectsFactory = EffectsFacory {
            return [
                ReverbEffect(samplingSettings: samplingSettings),
                HarmonizerEffect(samplingSettings: samplingSettings),
                PhaseVocoderEffect(samplingSettings: samplingSettings),
                DelayEffect(fadingFunctionA: 0.2,
                            fadingFunctionB: 0.2,
                            echoesCount: 3,
                            samplingSettings: samplingSettings,
                            timing: Timing(tactPart: .Half, tempo: 140)),
                AmpEffect(samplingSettings: samplingSettings)
            ]
        }
        return boardViewController
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
