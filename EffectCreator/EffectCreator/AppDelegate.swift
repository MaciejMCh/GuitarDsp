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
        let samplingSettings = AudioInterface.shared().samplingSettings
        let processor = RecordingProcessor(samplingSettings: samplingSettings, tempo: 120)
        let board = Board()
        board.effects = [makeDevelopmentEffect()]
        processor.activeBoard = board
        
        
        switch signal {
        case .input: AudioInterface.shared().use(processor)
        case .sine(let amplitude, let frequency):
            var packet: [Float] = []
            for i in 0..<100000 {
                let frame = sin(Float(i) * frequency) * amplitude
                packet.append(frame)
                if packet.count == Int(samplingSettings.framesPerPacket) {
                    processor.processBuffer(&packet)
                    packet.removeAll()
                }
            }
            NSApplication.shared().terminate(self)
        case .ramp(let slope):
            var packet: [Float] = []
            for i in 0..<100000 {
                let frame = Float(i) * slope
                packet.append(frame)
                if packet.count == Int(samplingSettings.framesPerPacket) {
                    processor.processBuffer(&packet)
                    packet.removeAll()
                }
            }
            NSApplication.shared().terminate(self)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate {
    func makeDevelopmentEffect() -> Effect {
        return WoEffect(samplingSettings: AudioInterface.shared().samplingSettings)
    }
    
    var signal: SignalGenerator {
        return .sine(amplitude: 0.1, frequency: 0.1)
//        return .ramp(slope: 0.000001)
    }
}
