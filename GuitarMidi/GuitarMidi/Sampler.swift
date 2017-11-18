//
//  Sampler2.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 22.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import Pitchy

struct AudioFile {
    let samples: [Float]
    let duration: Float
}

public class Sampler: Playing, MidiPlayer, WaveNode {
    public let id: String
    public static var xd: Sampler!
    let samplingSettings: SamplingSettings
    public var volume: FunctionVariable = EnvelopeFunction()
    private(set) var player: SamplePlayer
    lazy var output: SignalOutput = {SignalOutput(waveName: "sampler_\(id)_output") {[weak self] in self?.next(time: $0) ?? 0}}()
    public var sampleFilePath: String {
        didSet {
            lock = true
            player = Sampler.loadPlayer(path: sampleFilePath, samplingSettings: samplingSettings)
            lock = false
        }
    }
    private let ff = FlipFlop()
    private var lock = false
    
    static func loadPlayer(path: String, samplingSettings: SamplingSettings) -> SamplePlayer {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if isDirectory.boolValue && path.components(separatedBy: ".").last == "sampleset" {
            let json = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: path + "/contents.json"), options: .alwaysMapped), options: .mutableContainers) as! [String: String]
            
            let noteFromString: (String) -> Note = {
                let octave = Int(String($0.last!))!
                let letter = $0.substring(to: $0.index(of: $0.last!)!)
                return try! Note(letter: Note.Letter.init(rawValue: letter)!, octave: octave)
            }
            let audioFilesByNotes = json.map{(noteFromString($0.key), AudioFile.load(filePath: path + "/" + $0.value, samplingSettings: samplingSettings))}
            return SampleSetPlayer(samplingSettings: samplingSettings, audioFilesByNotes: audioFilesByNotes)
        } else {
            return SingleSamplePlayer(audioFile: .load(filePath: path, samplingSettings: samplingSettings))
        }
    }
    
    public init(sampleFilePath: String, samplingSettings: SamplingSettings, id: String? = nil) {
        self.samplingSettings = samplingSettings
        self.sampleFilePath = sampleFilePath
        player = Sampler.loadPlayer(path: sampleFilePath, samplingSettings: samplingSettings)
        self.id = id ?? IdGenerator.next()
        Sampler.xd = self
    }
    
    public func next(time: Int) -> Double {
        if lock {return 0}
        return ff.value(time: time) {
            self.player.nextSample() * self.volume.next(time: time)
        }
    }
    
    public func on() {
        volume.on()
        player.on()
    }
    
    public func off() {
        volume.off()
        player.off()
    }
    
    public func setFrequency(_ frequency: Double) {
        player.setFrequency(frequency)
    }
}

protocol SamplePlayer: MidiPlayer {
    func nextSample() -> Double
    var duration: Double {get}
    var samplesForView: [Float] {get}
}

class SingleSamplePlayer: SamplePlayer {
    private let audioFile: AudioFile
    private var time: Int = 0
    
    init(audioFile: AudioFile) {
        self.audioFile = audioFile
    }
    
    func nextSample() -> Double {
        defer {
            time += 1
        }
        
        if time < audioFile.samples.count {
            return Double(audioFile.samples[time])
        } else {
            return 0
        }
    }
    
    func setFrequency(_ frequency: Double) {}
    
    var duration: Double {
        return Double(audioFile.duration)
    }
    
    var samplesForView: [Float] {
        return audioFile.samples
    }
    
    func on() {
        time = 0
    }
}

class SampleSetPlayer: SamplePlayer {
    private let samplingSettings: SamplingSettings
    private let audioFilesByNotes: [(Note, AudioFile)]
    private let frequencyDomainProcessing: FrequencyDomainProcessing
    private let sampleSetLength: Int
    private let finePitchBufferLength: Int = 128
    private var finePitchBuffer: [Float] = []
    private var frequency: Double = 0
    private var time = 0

    init(samplingSettings: SamplingSettings, audioFilesByNotes: [(Note, AudioFile)]) {
        self.samplingSettings = samplingSettings
        self.audioFilesByNotes = audioFilesByNotes
        frequencyDomainProcessing = FrequencyDomainProcessing(samplingSettings: samplingSettings, fftFrameSize: 1024, osamp: 32)
        sampleSetLength = audioFilesByNotes.first!.1.samples.count
    }
    
    func setFrequency(_ frequency: Double) {
        self.frequency = frequency
    }
    
    func nextSample() -> Double {
        defer {
            time += 1
        }
        
        if time > sampleSetLength {
            return 0
        }
        
        let finePitchBufferTime = time % Int(samplingSettings.framesPerPacket)
        if finePitchBufferTime == 0 {
            refreshFinePitchBuffer()
        }
        return Double(finePitchBuffer[finePitchBufferTime])
    }
    
    private func refreshFinePitchBuffer() {
        let closestAudioFile = audioFilesByNotes.sorted{abs($0.0.frequency - self.frequency) < abs($1.0.frequency - self.frequency)}.first!
        let pitchShift = closestAudioFile.0.frequency / frequency
        var samplesToProcess = Array(closestAudioFile.1.samples[time..<time + finePitchBufferLength])
        frequencyDomainProcessing.pitchShift(&samplesToProcess, outdata: &finePitchBuffer, shift: Float(pitchShift))
    }
    
    var duration: Double {
        return Double(audioFilesByNotes.first!.1.duration)
    }
    
    var samplesForView: [Float] {
        return audioFilesByNotes.first!.1.samples
    }
}

