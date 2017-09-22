
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

let strokeDetectorXd = StrokeDetector()

class MidiOutputEffect: NSObject, Effect {
    let sendMidi = false
    
    let samplingSettings: SamplingSettings
    let pitchDetector: PitchDetector
    let midiServer: MidiServer
    let waveGenerator: WaveGenerator
    var recentNote = try! Note(index: 0)
    var noteIntegrator: [Int?] = Array(repeating: nil, count: 1000)
    var noteIndexIntegrator = NoteIndexIntegrator()
    
    init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
        pitchDetector = PitchDetector(samplingSettings: samplingSettings)
        waveGenerator = WaveGenerator(samplingSettings: samplingSettings)
        midiServer = MidiServer()
        super.init()
    }
    
    func processSample(_ inputSample: Sample, intoBuffer outputBuffer: UnsafeMutablePointer<Float>!) {
        var inputSignal: [Float] = Array(repeating: 0, count: Int(samplingSettings.framesPerPacket))
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            inputSignal[i] = inputSample.amp.advanced(by: i).pointee
        }
        
        let frequency = pitchDetector.detectPitch(inputSignal: inputSignal)
        
        let rms: () -> (Float) = {
            var output: Float = 0
            vDSP_rmsqv(inputSample.amp, 1, &output, UInt(self.samplingSettings.framesPerPacket))
            return output
        }
        let amplitude = rms()
        
        if strokeDetectorXd.process(processingSample: Double(amplitude)) == 0 {
            bzero(outputBuffer, Int(samplingSettings.packetByteSize))
            return
        }
        
        for i in 0..<Int(samplingSettings.framesPerPacket) {
            outputBuffer.advanced(by: i).pointee = Float(waveGenerator.nextSample(frequency: Double(frequency)))
        }
        
        guard sendMidi else {return}
        guard let note = try? Note(frequency: Double(frequency)) else {return}
        let integratedIndex = noteIndexIntegrator.integrate(sound: (noteIndex: note.index, volume: amplitude))
        if recentNote.index == integratedIndex.noteIndex {
            return
        } else {
            recentNote = note
        }
        midiServer.playNote(note: UInt8(abs(integratedIndex.noteIndex + 50)), on: true)
        
    }
}
