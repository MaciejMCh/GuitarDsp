
//  MidiOutputEffect.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 05.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import Pitchy
import Accelerate

public enum MidiEvent {
    case on
    case off
    case frequency(Double)
}

public class MidiOutput {
    let sendMidi = false
    let strokeDetector = StrokeDetector()
    let pitchDetector: PitchDetector
    let midiServer: MidiServer
    var recentNote = try! Note(index: 0)
    var noteIntegrator: [Int?] = Array(repeating: nil, count: 1000)
    var noteIndexIntegrator = NoteIndexIntegrator()
    var isOn = false
    
    public init(samplingSettings: SamplingSettings) {
        pitchDetector = PitchDetector(samplingSettings: samplingSettings)
        midiServer = MidiServer()
    }
    
    var prev = 1.0
    var cooldown = 6
    public func detectEvents(buffer: [Float]) -> [MidiEvent] {
        var events: [MidiEvent] = []
        
        var inputSignal = buffer
        
        let frequency = pitchDetector.detectPitch(inputSignal: inputSignal)
        
        let rms: () -> (Float) = {
            var output: Float = 0
            vDSP_rmsqv(&inputSignal, 1, &output, UInt(buffer.count))
            return output
        }
        let amplitude = Double(rms())
        
        let treshold = 0.006
        let margin = treshold * 0.2
        
        let diff = amplitude / prev
        prev = amplitude
        
        cooldown -= 1
        
        if diff > 2.5 {
            if cooldown < 0 {
//                debugPrint(diff)
                events.append(.on)
                isOn = true
                cooldown = 6
            }
        }
//        debugPrint(diff)
        
        if !isOn {
//            if amplitude > treshold {
//                events.append(.on)
//                isOn = true
//            }
        } else {
            if amplitude < treshold - margin {
                events.append(.off)
                isOn = false
            }
        }
        
        events.append(.frequency(0.25 * Double(frequency)))
        
        return events
        
//        guard sendMidi else {return}
//        guard let note = try? Note(frequency: Double(frequency)) else {return}
//        let integratedIndex = noteIndexIntegrator.integrate(sound: (noteIndex: note.index, volume: Float(amplitude)))
//        if recentNote.index == integratedIndex.noteIndex {
//            return
//        } else {
//            recentNote = note
//        }
//        midiServer.playNote(note: UInt8(abs(integratedIndex.noteIndex + 50)), on: true)
        
    }
}
