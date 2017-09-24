//
//  PropertyTimeFunction.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 19.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

class EnvelopeFunction: FunctionVariable {
    enum State {
        case on
        case off(releaseStartTime: Double, releaseStartValue: Double)
    }
    
    var duration: Double = 100000
    var delay: Double = 0
    var attack: Double = 0.1
    var hold: Double = 0.3
    var decay: Double = 0.2
    var sustain: Double = 0.4
    var release: Double = 0.3
    
    var attackBezier: CubicBezier? = .fadeOut
    var decayBezier: CubicBezier? = .fadeOut
    var releaseBezier: CubicBezier? = .fadeOut
    
    private var state = State.on
    private var time: Double = 0
    
    func on() {
        state = .on
        time = 0
    }
    
    func off() {
        time -= 1
        state = .off(releaseStartTime: time + 1, releaseStartValue: nextSample())
    }
    
    var value: Double {
        return nextSample()
    }
    
    func nextSample() -> Double {
        defer {
            time += 1
        }
        
        let progress = {(range: Range<Double>, pointer: Double) -> Double in
            return (pointer - range.lowerBound) / (range.upperBound - range.lowerBound)
        }
        
        switch state {
        case .on:
            let delayTime = 0..<delay * duration
            let attackTime = delayTime.upperBound..<delayTime.upperBound + attack * duration
            let holdTime = attackTime.upperBound..<attackTime.upperBound + hold * duration
            let decayTime = holdTime.upperBound..<holdTime.upperBound + decay * duration
            
            switch time {
            case delayTime: return 0
            case attackTime:
                let progress = progress(attackTime, time)
                if let attackBezier = attackBezier {
                    return attackBezier.y(x: progress)
                } else {
                    return progress
                }
            case holdTime: return 1
            case decayTime:
                let progress = progress(decayTime, time)
                if let decayBezier = decayBezier {
                    return 1 - (decayBezier.y(x: progress) * (1 - sustain))
                } else {
                    return 1 - (progress * (1 - sustain))
                }
            default: return sustain
            }
        case .off(let releaseStartTime, let releaseStartValue):
            let releaseTime = releaseStartTime..<releaseStartTime + release * duration
            
            switch time {
            case releaseTime:
                let progress = progress(releaseTime, time)
                if let releaseBezier = releaseBezier {
                    return releaseStartValue * (1 - releaseBezier.y(x: progress))
                } else {
                    return releaseStartValue * (1 - progress)
                }
            default: return 0
            }
        }
        
        
    }
}
