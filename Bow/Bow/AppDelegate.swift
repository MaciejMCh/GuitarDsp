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
    var allEffects: () -> [Effect] = {
        let samplingSettings = AudioInterface.shared().samplingSettings
        return [ReverbEffect(samplingSettings: samplingSettings),
        HarmonizerEffect(samplingSettings: samplingSettings),
        PhaseVocoderEffect(samplingSettings: samplingSettings),
        DelayEffect(fadingFunctionA: 0.2,
        fadingFunctionB: 0.2,
        echoesCount: 3,
        samplingSettings: samplingSettings,
        timing: Timing(tactPart: .Half, tempo: 140)),
        AmpEffect(samplingSettings: samplingSettings)]
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared().windows.first!.contentViewController = initialController()
        
        let samplingSettings = AudioInterface.shared().samplingSettings
        let board = Board()
//        board.effects = [AmpEffect(samplingSettings: samplingSettings)]
        board.effects = allEffects()
        let storage = BoardsStorage(effectsFactory: EffectsFacory(samplingSettings: AudioInterface.shared().samplingSettings, all: allEffects))
        storage.save(board: board, name: "hehe")
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
        boardViewController.effectsFactory = EffectsFacory(samplingSettings: samplingSettings) {
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
    
    @IBAction func openBoardAction(_ sender: Any) {
        let topController = NSApplication.shared().windows.first!.contentViewController
        if let boardTopController = topController as? BoardViewController {
            let boardsStorage = BoardsStorage(effectsFactory: EffectsFacory(samplingSettings: AudioInterface.shared().samplingSettings, all: allEffects))
            let searchViewController = SearchViewController.make()
            searchViewController.searchForBoards(storage: boardsStorage) { [weak boardTopController] in
                boardTopController?.board = $0
            }
            NSApplication.shared().windows.first!.contentViewController?.presentViewControllerAsModalWindow(searchViewController)
        }
    }
}
