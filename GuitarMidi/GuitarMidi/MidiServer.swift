//
//  MidiServer.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 11.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import MIDIKit

class MidiServer {
    let name = "GuitarMidi"
    
    private lazy var client: MKClient = {
        MKClient(name: self.name)
    }()
    
    private lazy var outputSource: MKVirtualSource = {
        let outputSource = MKVirtualSource(name: self.name, client: self.client)!
        outputSource.isOnline = true
        return outputSource
    }()
    
    func playNote(note: UInt8, on: Bool) {
        outputSource.receivedMessage(MKMessage.noteOnMessage(withKey: note, velocity: 100))
    }
    
    deinit {
        client.dispose()
        outputSource.isOnline = false
    }
}
