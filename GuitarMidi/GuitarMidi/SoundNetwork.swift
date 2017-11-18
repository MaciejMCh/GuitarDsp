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
    let next: (Int) -> Double
    
    init(next: @escaping (Int) -> Double) {
        self.next = next
    }
}

public class SignalInput {
    var output: SignalOutput?
    
    init() {}
}
