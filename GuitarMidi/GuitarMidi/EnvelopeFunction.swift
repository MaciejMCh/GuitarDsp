//
//  PropertyTimeFunction.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 19.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import GuitarMidi

public class EnvelopeFunction: FunctionVariable {
    enum State {
        case on
        case off(releaseStartTime: Double, releaseStartValue: Double)
    }
    
    public var duration: Double = AudioInterface.shared().samplingSettings.samplesInSecond()
    public var delay: Double = 0
    public var attack: Double = 0.1
    public var hold: Double = 0.3
    public var decay: Double = 0.2
    public var sustain: Double = 0.4
    public var release: Double = 0.3
    public var volume: Double = 1.0
    
    public var attackBezier: CubicBezier? = .fadeOut
    public var decayBezier: CubicBezier? = .fadeOut
    public var releaseBezier: CubicBezier? = .fadeOut
    
    private var state = State.on
    private var time: Double = 0
    
    public init() {}
    
    public func on() {
        state = .on
        time = 0
    }
    
    public func off() {
        time -= 1
        state = .off(releaseStartTime: time + 1, releaseStartValue: nextSample())
    }
    
    public var value: Double {
        return nextSample()
    }
    
    public func nextSample() -> Double {
        defer {
            time += 1
        }
        
        let progress = {(range: Range<Double>, pointer: Double) -> Double in
            return (pointer - range.lowerBound) / (range.upperBound - range.lowerBound)
        }
        
        let envelopeOutput: Double
        switch state {
        case .on:
            let delayTime = 0..<delay * duration
            let attackTime = delayTime.upperBound..<delayTime.upperBound + attack * duration
            let holdTime = attackTime.upperBound..<attackTime.upperBound + hold * duration
            let decayTime = holdTime.upperBound..<holdTime.upperBound + decay * duration
            
            switch time {
            case delayTime: envelopeOutput = 0
            case attackTime:
                let progress = progress(attackTime, time)
                if let attackBezier = attackBezier {
                    envelopeOutput = attackBezier.y(x: progress)
                } else {
                    envelopeOutput = progress
                }
            case holdTime: envelopeOutput = 1
            case decayTime:
                let progress = progress(decayTime, time)
                if let decayBezier = decayBezier {
                    envelopeOutput = 1 - (decayBezier.y(x: progress) * (1 - sustain))
                } else {
                    envelopeOutput = 1 - (progress * (1 - sustain))
                }
            default: envelopeOutput = sustain
            }
        case .off(let releaseStartTime, let releaseStartValue):
            let releaseTime = releaseStartTime..<releaseStartTime + release * duration
            
            switch time {
            case releaseTime:
                let progress = progress(releaseTime, time)
                if let releaseBezier = releaseBezier {
                    envelopeOutput = releaseStartValue * (1 - releaseBezier.y(x: progress))
                } else {
                    envelopeOutput = releaseStartValue * (1 - progress)
                }
            default: envelopeOutput = 0
            }
        }
        return envelopeOutput * volume
        
    }
}
