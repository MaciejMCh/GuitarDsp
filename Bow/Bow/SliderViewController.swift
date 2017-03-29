//
//  SliderViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 28.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import RxSwift

class SliderViewController: NSViewController {
    var configuration: Configuration!
    private var valueType: ValueType!
    
    @IBOutlet weak var sliderSpaceView: NSView!
    @IBOutlet weak var sliderFillView: NSView!
    @IBOutlet weak var valueLabel: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var progressBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollDetectingView: ScrollDetectingView!
    
    private var scrollDidUpdate: (() -> ())?
    private var valuesCount: Int!
    private var valueIndex: Int! {
        return Int(continousIndex * indexScale)
    }
    private var continousIndex: Float = 0
    private let indexScale: Float = 10.0
    private var currentValue: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearence()
        
        scrollDetectingView.reportScroll = {[weak self] (change: CGPoint) in
            guard let wSelf = self else {return}
            wSelf.continousIndex = wSelf.continousIndex + Float(change.y)
            wSelf.updateValue()
            wSelf.updateViews()
            wSelf.scrollDidUpdate?()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateViews()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        updateViews()
    }
    
    private func setupAppearence() {
        sliderSpaceView.wantsLayer = true
        sliderSpaceView.layer!.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
        sliderSpaceView.layer!.cornerRadius = 10
        sliderSpaceView.layer!.masksToBounds = true
        
        sliderFillView.wantsLayer = true
        sliderFillView.layer?.backgroundColor = configuration.mainColor.cgColor
        
        nameLabel.stringValue = configuration.valueName
    }
    
    lazy var valueChange: Observable<Float> = {
        return Observable.create { [weak self] observer in
            let cancel = Disposables.create {
                self?.scrollDetectingView.reportScroll = nil
            }
            
            self?.scrollDidUpdate = {
                guard let wSelf = self else {return}
                observer.on(.next(wSelf.currentValue))
            }

            return cancel
        }
    }()
    
    func setup(valueType: ValueType, currentValue: Float) {
        self.valueType = valueType
        valuesCount = valueType.valuesCount()
        continousIndex = Float(valueType.indexOfValue(value: currentValue)) / indexScale
        updateValue()
        updateViews()
    }
    
    private func updateValue() {
        currentValue = valueType.valueAtIndex(index: valueIndex)
    }
    
    private func updateViews() {
        valueLabel?.stringValue = String(format: "%.2f", currentValue)
        let progress = Float(valueType.indexOfValue(value: currentValue)) / Float(valueType.valuesCount())
        progressBarHeightConstraint?.constant = CGFloat(progress) * sliderSpaceView.frame.height
    }
    
}

extension SliderViewController {
    struct Configuration {
        let mainColor: NSColor
        let valueName: String
    }
}

extension SliderViewController {
    enum ValueType {
        case continous(range: Range<Float>, step: Float)
        case discrete(values: [Float])
    }
}

extension SliderViewController.ValueType {
    func valuesCount() -> Int {
        switch self {
        case .continous(let range, let step): return Int((range.upperBound - range.lowerBound) / step)
        case .discrete(let values): return values.count
        }
    }
    
    func indexOfValue(value: Float) -> Int {
        switch self {
        case .continous(let range, let step): return Int((value - range.lowerBound) / step)
        case .discrete(let values):
            var i = 0
            for valueElement in values {
                if valueElement > value {
                    return i
                }
                i += 1
            }
            return values.count
        }
    }
    
    func valueAtIndex(index: Int) -> Float {
        let _valuesCount = valuesCount()
        var firstPositive = index
        while firstPositive < 0 {
            firstPositive += _valuesCount
        }
        let circleIndex = firstPositive % _valuesCount
        switch self {
        case .continous(let range, let step): return range.lowerBound + (Float(circleIndex) * step)
        case .discrete(let values): return values[circleIndex]
        }
    }
}
