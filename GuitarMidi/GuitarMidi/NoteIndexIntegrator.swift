//
//  NoteIndexIntegrator.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 11.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

class NoteIndexIntegrator {
    typealias Sound = (noteIndex: Int, volume: Float)
    
    enum FadingFunction {
        case linear(a: Float, b: Float)
        case exponential(a: Float)
        
        func fade(buffer: [Sound]) -> [Sound] {
//            debugPrint(buffer)
            switch self {
            case .exponential(let a): return buffer.map {(noteIndex: $0.noteIndex, volume: $0.volume * a)}
            case .linear(let a, let b):
                var x = 0
                let nextX: () -> Int = {
                    defer {x = x + 1}
                    return x
                }
                return buffer.map {(noteIndex: $0.noteIndex, volume: $0.volume * a * Float(nextX()))}
            }
        }
    }
    
    private let length = 16
    private let fadingFunction: FadingFunction = .exponential(a: 0.9)
    
    private lazy var buffer: [Sound] = {
        return Array(repeating: (noteIndex: 0, volume: 0), count: self.length)
    }()
    
    func integrate(sound: Sound) -> Sound {
        buffer.append(sound)
        buffer.remove(at: 0)
        
        buffer = fadingFunction.fade(buffer: buffer)
        
        var volumesByIndices: [Int: Float] = [:]
        for sound in buffer {
            volumesByIndices[sound.noteIndex] = (volumesByIndices[sound.noteIndex] ?? 0) + sound.volume
        }
        return volumesByIndices.map {($0.key, $0.value)}.sorted {$0.1 > $1.1}.first ?? (noteIndex: 0, volume: 0)
    }
}
