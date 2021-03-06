//
//  WaveGenerator.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp

let sign: (Double) -> Double = {$0 > 0 ? 1 : -1}

public enum WaveShape {
    case sine
    case square
    case triangle
    case sawtooth
    case circle
    
    public static func all() -> [WaveShape] {
        return [.sine, .square, .triangle, .sawtooth, .circle]
    }
}

public class WaveGenerator {
    let samplingSettings: SamplingSettings
    public var waveShape: WaveShape = .sine
    
    private var x: Double = 0
    
    public init(samplingSettings: SamplingSettings) {
        self.samplingSettings = samplingSettings
    }
    
    public func nextSample(frequency: Double) -> Double {
        let timeShift = frequency / Double(self.samplingSettings.frequency) * Double.pi * 2
        x += timeShift
        
        switch waveShape {
        case .sine: return sin(x)
        case .square: return sign(sin(x))
        case .triangle:
            let periodProgress = x.truncatingRemainder(dividingBy: Double.pi * 2)
            switch periodProgress {
            case 0..<Double.pi * 0.5: return periodProgress / (Double.pi / 2)
            case Double.pi * 0.5..<Double.pi * 1.5: return 2 - (periodProgress / (Double.pi / 2))
            default: return (periodProgress / (Double.pi / 2)) - 4
            }
        case .sawtooth: return (x + Double.pi * 1.5).truncatingRemainder(dividingBy: Double.pi * 2) / (Double.pi) - 1
        case .circle:
            let periodProgress = x.truncatingRemainder(dividingBy: Double.pi * 2)
            switch periodProgress {
            case 0..<Double.pi:
                let r2 = pow(Double.pi * 0.5, 2)
                let x2 = pow(periodProgress - Double.pi * 0.5, 2)
                return(sqrt(r2 - x2)) / (Double.pi * 0.5)
            default:
                let r2 = pow(Double.pi * 0.5, 2)
                let x2 = pow(periodProgress - Double.pi * 1.5, 2)
                return(sqrt(r2 - x2)) / (Double.pi * -0.5)
            }
        }
    }
}
