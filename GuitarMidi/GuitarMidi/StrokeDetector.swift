//
//  StrokeDetector.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 13.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

// https://stackoverflow.com/questions/43583302/peak-detection-for-growing-time-series-using-swift/43607179#43607179

class StrokeDetector {
    var threshold: Double = 0.00001
    var influence: Double = 0.0
    
    var lag = 10 {
        didSet {
            filteredSamples = Array(repeating: 0, count: self.lag)
        }
    }
    
    var previousAvgFilter: Double = 0
    var previousStdFilter: Double = 0
    
    private lazy var filteredSamples: [Double] = {
        Array(repeating: 0, count: self.lag)
    }()
    
    func process(processingSample: Double) -> Int {
        var output: Int = 0
        if abs(processingSample - previousAvgFilter) > threshold * previousStdFilter {
            if processingSample > previousAvgFilter {
                output = 1
            }
            filteredSamples.append(influence*processingSample + (1 - influence) * filteredSamples.last!)
            filteredSamples.remove(at: 0)
        } else {
            output = 0
            filteredSamples.append(processingSample)
            filteredSamples.remove(at: 0)
        }
        previousAvgFilter = arithmeticMean(array: filteredSamples)
        previousStdFilter = standardDeviation(array: filteredSamples)
        return output
    }
    
    private func arithmeticMean(array: [Double]) -> Double {
        var total: Double = 0
        for number in array {
            total += number
        }
        return total / Double(array.count)
    }
    
    private func standardDeviation(array: [Double]) -> Double {
        let length = Double(array.count)
        let avg = array.reduce(0, {$0 + $1}) / length
        let sumOfSquaredAvgDiff = array.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }

}
