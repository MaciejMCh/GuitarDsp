//
//  SineWaveGenerator.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 14.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

let sign: (Double) -> Double = {$0 > 0 ? 1 : -1}

class SineWaveGenerator {
    let signalLength = 1000
    
    var t = 0
    
    func generate() -> [Float] {
        return []
        //        let signal = Function.circle.period(samplesCount: signalLength)
        return Function.circle.period(samplesCount: signalLength)
//        let signal = Function.mirrordriven(function: .sine, level: 0.8, bounce: 1.4).period(samplesCount: signalLength)
        
//        PlotViewController.passData(dict: ["test": signal])
        
        
        //        PlotViewController.passData(dict: ["sine": Function.sine.period(samplesCount: 1000)])
        //        PlotViewController.passData(dict: ["square": Function.square.period(samplesCount: 1000)])
        //        PlotViewController.passData(dict: ["triangle": Function.triangle.period(samplesCount: 1000)])
        //        PlotViewController.passData(dict: ["shaped": Function.shaped(f1: .sine, f2: .triangle, percent: 0.5).period(samplesCount: 1000)])
        //
//        PlotViewController.me.draw()
        
//        return signal
    }
    
    func generate(percent: Float) -> [Float] {
        return Function.shaped(f1: .sine, f2: .circle, percent: percent).period(samplesCount: signalLength)
    }
}

extension SineWaveGenerator {
    indirect enum Function {
        case sine
        case square
        case triangle
        case circle
        case shaped(f1: Function, f2: Function, percent: Float)
//        case overdriven(function: Function, level: Float)
//        case mirrordriven(function: Function, level: Float, bounce: Float)
    }
}

extension SineWaveGenerator.Function {
    func period(samplesCount: Int) -> [Float] {
        switch self {
        case .sine:
            var sineSignal: [Float] = []
            for i in 0..<samplesCount {
                sineSignal.append(sin(Float(i) * Float.pi * 2 / Float(samplesCount)))
            }
            return sineSignal
        case .square: return SineWaveGenerator.Function.sine.period(samplesCount: samplesCount).map{$0 > 0 ? 1 : -1}
        case .triangle:
            var triangleSignal: [Float] = []
            for i in 0..<samplesCount {
                let x = Float(i) * Float.pi * 2 / Float(samplesCount)
                
                if x < Float.pi / 2 {
                    triangleSignal.append(x * 2 / Float.pi)
                } else if x < Float.pi * 1.5 {
                    triangleSignal.append((-x * 2 / Float.pi) + 2)
                } else {
                    triangleSignal.append((x * 2 / Float.pi) - 4)
                }
            }
            return triangleSignal
        case .shaped(let f1, let f2, let percent): return zip(f1.period(samplesCount: samplesCount), f2.period(samplesCount: samplesCount)).map{($0.0 * (1 - percent)) + ($0.1 * percent)}
        case .circle:
            var circleSignal: [Float] = []
            for i in 0..<samplesCount / 2 {
                let x = Float((i * 4) - samplesCount) / Float(samplesCount)
                circleSignal.append(sqrtf(1 - (x * x)))
            }
            
            let signalHalfLength = samplesCount / 2
            for i in signalHalfLength ..< samplesCount {
                circleSignal.append(-circleSignal[i - signalHalfLength])
            }
            return circleSignal
//        case .overdriven(let function, let level): return function.period(samplesCount: samplesCount).map{min(level, abs($0)) / level * sign($0)}
//        case .mirrordriven(let function, let level, let bounce): return function.period(samplesCount: samplesCount).map {
//            guard abs($0) > level else {return $0}
//            return $0 + ((abs($0) - level) * -sign($0) * bounce * 2)
//            }
        }
    }
}
