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
        setupFileSystem()
        EffectPrototype.effectsFactory = EffectsFacory(samplingSettings: AudioInterface.shared().samplingSettings)
        NSApplication.shared().windows.first!.contentViewController = initialController()
    }
    
    func initialController() -> NSViewController {
        let samplingSettings = AudioInterface.shared().samplingSettings
        let processor = Processor(samplingSettings: samplingSettings, tempo: 120)
        AudioInterface.shared().use(processor)
        let effectsFactory = EffectsFacory(samplingSettings: samplingSettings)
        let looperEffect = effectsFactory.makeLooper()
        
        let setupViewController = SetupViewController.make()
        setupViewController.setup(setup: SetupViewController.Setup(looperEffect: looperEffect, effectsFactory: effectsFactory) {
            processor.activeBoard = $0
        })
        
        return setupViewController
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func setupFileSystem() {
        for path in [BoardPrototype.typeName, EffectPrototype.typeName].map({Storage(typeName: $0).storagePath}) {
            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

class BowMenu: NSMenu {
    @IBOutlet weak var newMenuItem: NSMenuItem!
    @IBOutlet weak var saveMenuItem: NSMenuItem!
    @IBOutlet weak var openMenuItem: NSMenuItem!
}

extension NSViewController {
    var bowMenu: BowMenu? {
        return NSApplication.shared().menu as? BowMenu
    }
}
