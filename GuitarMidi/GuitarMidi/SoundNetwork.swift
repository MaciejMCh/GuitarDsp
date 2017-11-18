//
//  SoundNetwork.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 06.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

public class SignalOutput: NSObject {
    let waveName: String
    let next: (Int) -> Double
    
    init(waveName: String, next: @escaping (Int) -> Double) {
        self.waveName = waveName
        self.next = next
    }
}

public class SignalInput {
    var output: SignalOutput?
    
    init() {}
}
