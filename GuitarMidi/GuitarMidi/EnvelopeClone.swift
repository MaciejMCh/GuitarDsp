//
//  EnvelopeClone.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 06.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

extension EnvelopeFunction {
    func makeClone() -> EnvelopeFunction {
        let cloneEnvelopeFunction = EnvelopeFunction()
        cloneEnvelopeFunction.hold = hold
        cloneEnvelopeFunction.decay = decay
        cloneEnvelopeFunction.delay = delay
        cloneEnvelopeFunction.volume = volume
        cloneEnvelopeFunction.attack = attack
        cloneEnvelopeFunction.sustain = sustain
        cloneEnvelopeFunction.release = release
        cloneEnvelopeFunction.duration = duration
        cloneEnvelopeFunction.decayBezier = decayBezier
        cloneEnvelopeFunction.attackBezier = attackBezier
        cloneEnvelopeFunction.releaseBezier = releaseBezier
        return cloneEnvelopeFunction
    }
}
