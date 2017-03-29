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
        let processor = Processor(samplingSettings: AudioInterface.shared().samplingSettings, tempo: 120)
        AudioInterface.shared().use(processor)
        let board = Board()
        board.effects = [
            ReverbEffect(samplingSettings: AudioInterface.shared().samplingSettings),
            HarmonizerEffect(samplingSettings: AudioInterface.shared().samplingSettings)
        ]
        let boardViewController = BoardViewController.make()
        boardViewController.board = board
        return boardViewController
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
