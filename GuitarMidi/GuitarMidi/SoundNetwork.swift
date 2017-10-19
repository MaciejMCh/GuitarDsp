//
//  SoundNetwork.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 06.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

public protocol SoundNetworkElementsCreator {
    func makeOscilator() -> Oscilator
    func makeFoldback() -> FoldbackWaveEffect
    func makeAmp() -> AmpWaveEffect
    func makeConstant() -> Constant
    func makeSampler() -> Sampler
    func makeEnvelope() -> EnvelopeFunction
    func makeSum() -> SumWaveNode
    func makeWaveShaper() -> WaveShaper
    func makeOverdrive() -> OverdriveWaveEffect
    func makeLpf() -> LowpassFilterEffect
}

public class SignalOutput {
    let next: (Int) -> Double
    
    init(next: @escaping (Int) -> Double) {
        self.next = next
    }
}

public class SignalInput {
    var output: SignalOutput?
    
    init() {}
}
