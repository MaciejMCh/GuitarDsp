//
//  SoundNetwork.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 06.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

struct SoundNetworkElementsCreator {
    let samplingSettings: SamplingSettings
    
    func makeOscilator() -> Oscilator {
        return Oscilator(samplingSettings: samplingSettings)
    }
    
    func makeFoldback() -> FoldbackWaveEffect {
        return FoldbackWaveEffect(treshold: 0.8)
    }
    
    func makeAmp() -> AmpWaveEffect {
        return AmpWaveEffect()
    }
    
    func makeConstant() -> Double {
        return 1
    }
    
    func makeSampler() -> Sampler {
        return Sampler(sampleFilePath: "/Users/maciejchmielewski/Documents/GuitarDsp/samples/kicks/808-Kicks03.wav", samplingSettings: samplingSettings)
    }
    
    func makeEnvelope() -> EnvelopeFunction {
        return EnvelopeFunction()
    }
    
}

public class SignalOutput {
    let next: (Int) -> Double
    
    init(next: @escaping (Int) -> Double) {
        self.next = next
    }
}

class SignalInput {
    var output: SignalOutput?
    
    init() {}
}

class SoundNetwork {
    let creator: SoundNetworkElementsCreator
    let output = SignalInput()
    
    init(creator: SoundNetworkElementsCreator) {
        self.creator = creator
    }
}

extension SoundNetwork {
    static func mocked() -> SoundNetwork {
        let network = SoundNetwork(creator: SoundNetworkElementsCreator(samplingSettings: AudioInterface.shared().samplingSettings))
        
        let foldback = network.creator.makeFoldback()
        let oscilator = network.creator.makeOscilator()
        
        network.output.output = foldback.output
        foldback.input?.output = oscilator.output
        
        return network
    }
}

extension FoldbackWaveEffect {
    var output: SignalOutput {
        return "" as! SignalOutput
    }
    
    var input: SignalInput? {
        get {return "" as! SignalInput}
        set {}
    }
}
