
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

class MidiOutputEffect: NSObject, Effect {
    let samplingSettings: SamplingSettings
    let pitchDetector: PitchDetector
    let midiServer: MidiServer
    let sineWaveGenerator: SineWaveGenerator
    var recentNote = try! Note(index: 0)
    var noteIntegrator: [Int?] = Array(repeating: nil, count: 1000)
    var noteIndexIntegrator = NoteIndexIntegrator()
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        pitchDetector = PitchDetector(samplingSettings: samplingSettings)
        sineWaveGenerator = SineWaveGenerator()
        midiServer = MidiServer()
        super.init()
    }
    
    func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        var inputSignal: [Float] = Array(repeating: 0, count: Int(samplingSettings.framesPerPacket))
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            inputSignal[i] = inputSample.amp.advanced(by: i).pointee
        }
        
        let frequency = pitchDetector.detectPitch(inputSignal: inputSignal)
        sineWaveGenerator
        
        let rms: () -> (Float) = {
            var output: Float = 0
            vDSP_rmsqv(inputSample.amp, 1, &output, UInt(self.samplingSettings.framesPerPacket))
            return output
        }
        let amplitude = rms()
        
//        if amplitude < 0.001 {
//            return
//        }
        guard let note = try? Note(frequency: Double(frequency)) else {return}
        let integratedIndex = noteIndexIntegrator.integrate(sound: (noteIndex: note.index, volume: amplitude))
        if recentNote.index == integratedIndex.noteIndex {
            return
        } else {
            recentNote = note
        }
        midiServer.playNote(note: UInt8(abs(integratedIndex.noteIndex + 50)), on: true)
        
//        debugPrint(integratedIndex)
        
        return
        
        noteIntegrator.append(note.index)
        noteIntegrator.remove(at: 0)
        
        let noteIndex = noteIntegrator.flatMap {
            if let unwrapped = $0 {
                return unwrapped
            }
            return nil
            }.reduce(0, +) / noteIntegrator.count
        
        if noteIndex == recentNote.index {
            return
        } else {
            let noteIndex = noteIndex > 0 ? noteIndex : -noteIndex
//            debugPrint(noteIndex)
            midiServer.playNote(note: UInt8(noteIndex + 50), on: true)
            recentNote = note
        }
        
        memcpy(outputBuffer, inputSample.amp, Int(samplingSettings.packetByteSize))
//        debugPrint(frequency)
//
//        let sineWave = sineWaveGenerator.generate(samples: 128, frequency: frequency * 0.00001)
//        for i in 0..<Int(samplingSettings.framesPerPacket) {
//            outputBuffer.advanced(by: i).pointee = sineWave[i]
//        }
        
//        let f: Float = 0.01
//        let s: Int = 128
//
//        var r: [Float] = []
//
//        r.append(contentsOf: sineWaveGenerator.generate(samples: s, frequency: f))
//        r.append(contentsOf: sineWaveGenerator.generate(samples: s, frequency: f))
//        r.append(contentsOf: sineWaveGenerator.generate(samples: s, frequency: f))
//        let str = r.map{"\($0) "}.reduce("", +)
        
//        debugPrint(str)
    }
}
