//
//  AppDelegate.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 05.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Cocoa
import GuitarDsp

var bass808xD = Bass808(samplingSettings: AudioInterface.shared().samplingSettings)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBAction func playAction(sender: Any?) {
        bass808xD.on()
    }
    
    @IBAction func stopAction(sender: Any?) {
        bass808xD.off()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        return
        
//        bowMenu?.openMenuItem.target = self
//        bowMenu?.openMenuItem.action = #selector(openAction)
        
//        return
//        return
//        let lenght = 50
//
//        let integrator = NoteIndexIntegrator()
//        var integrateds: [Int] = []
//
//        var indices: [Int] = []
//        for i in 0..<lenght {
//            let index = i < (lenght / 2) ? 2 : 1
//            indices.append(index)
//
//            let sound: NoteIndexIntegrator.Sound = (noteIndex: index, volume: 1 * index)
//            let integratedSound = integrator.integrate(sound: sound)
//            integrateds.append(integratedSound.noteIndex)
//        }
//
//
//        let indicesString = indices.map{"\($0) "}.reduce("", +)
//        let integratedsString = integrateds.map{"\($0) "}.reduce("", +)
//
//        debugPrint(indicesString)
//        debugPrint(integratedsString)
        
        let samplingSettings = AudioInterface.shared().samplingSettings
        let processor = Processor(samplingSettings: samplingSettings, tempo: 120)
        let board = Board()
        let developmentEffect = makeDevelopmentEffect()
        board.effects = [developmentEffect]
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
            //            PlotViewController.passData(dict: developmentEffect.data)
//            PlotViewController.me.draw()
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
            //            PlotViewController.passData(dict: developmentEffect.data)
//            PlotViewController.me.draw()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate {
    func makeDevelopmentEffect() -> Effect {
//        return MidiOutputEffect(samplingSettings: AudioInterface.shared().samplingSettings)
        return Bass808Effect(samplingSettings: AudioInterface.shared().samplingSettings)
    }
    
    var signal: SignalGenerator {
        return .input
        //        return .sine(amplitude: 0.1, frequency: 0.1)
        //        return .ramp(slope: 0.000001)
    }
}

enum SignalGenerator {
    case sine(amplitude: Float, frequency: Float)
    case ramp(slope: Float)
    case input
}
