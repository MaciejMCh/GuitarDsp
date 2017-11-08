//
//  Sequencer.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 08.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

class Sequencer: MidiOutput {
    private var events: [MidiEvent] = []
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.events.append(.frequency(200))
            self?.events.append(.on)
        }
    }
    
    func detectEvents(buffer: [Float]) -> [MidiEvent] {
        defer {
            events.removeAll()
        }
        return events
    }
}
