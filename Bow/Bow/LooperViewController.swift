//
//  LooperViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 05.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarDsp
import HexColors

class LooperEffectViewController: NSViewController {
    var looperEffect: LooperEffect!
    
    @IBOutlet weak var barView0: NSView!
    @IBOutlet weak var barView1: NSView!
    @IBOutlet weak var barView2: NSView!
    @IBOutlet weak var barView3: NSView!
    @IBOutlet weak var barView4: NSView!
    
    @IBOutlet weak var buttonView0: NSView!
    @IBOutlet weak var buttonView1: NSView!
    @IBOutlet weak var buttonView2: NSView!
    @IBOutlet weak var buttonView3: NSView!
    @IBOutlet weak var buttonView4: NSView!
    
    @IBOutlet weak var tempoTapView: TapView!
    @IBOutlet weak var tempoAnimationView: NSView!
    
    var loopViews: [LoopView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoopViews()
        updateLoopViews()
        setupTapDetector()
    }
    
    func setupTapDetector() {
        tempoTapView.wantsLayer = true
        tempoTapView.layer?.cornerRadius = 8
        tempoTapView.layer?.backgroundColor = NSColor("4F4F4F")!.cgColor
        
        tempoAnimationView.wantsLayer = true
        tempoAnimationView.layer?.backgroundColor = NSColor.white.withAlphaComponent(1).cgColor
        
        looperEffect.loopDidBegin = { [weak self] (looperEffect) in
            DispatchQueue.main.async {
                guard let tempoAnimationView = self?.tempoAnimationView else {return}
                let flashAnimation = CABasicAnimation(keyPath: "backgroundColor")
                flashAnimation.fromValue = NSColor.white.withAlphaComponent(1).cgColor
                flashAnimation.toValue = NSColor.white.withAlphaComponent(0.5).cgColor
                let quatersCount = 4 * looperEffect.tactsCount
                flashAnimation.duration = Double(looperEffect.durationInSeconds) / Double(quatersCount)
                flashAnimation.repeatCount = Float(quatersCount)
                tempoAnimationView.layer?.add(flashAnimation, forKey: "backgroundColor")
                
                let progressAnimation = CABasicAnimation(keyPath: "position.y")
                progressAnimation.fromValue = 0
                progressAnimation.toValue = -tempoAnimationView.layer!.frame.height
                progressAnimation.duration = Double(looperEffect.durationInSeconds)
                tempoAnimationView.layer?.add(progressAnimation, forKey: "position.y")
            }
        }
        
        let tapsCount = 6
        var taps: [Double] = Array(repeating: 0, count: tapsCount)
        tempoTapView.tap = { [weak looperEffect] in
            taps.remove(at: 0)
            taps.append(NSDate().timeIntervalSince1970)
            var intervals: [Double] = []
            for i in 0..<tapsCount - 1 {
                intervals.append(taps[i + 1] - taps[i])
            }
            let average = intervals.reduce(0, +) / Double(intervals.count)
            let errors = intervals.map{average - $0}
            let maxError = errors.map{abs($0)}.max()!
            if maxError < 0.05 {
                let tempo = (60 / average)
                looperEffect?.updateTempo(Float(tempo))
            }
        }
    }
    
    func setupLoopViews() {
        loopViews.append(LoopView(bar: barView0, button: buttonView0))
        loopViews.append(LoopView(bar: barView1, button: buttonView1))
        loopViews.append(LoopView(bar: barView2, button: buttonView2))
        loopViews.append(LoopView(bar: barView3, button: buttonView3))
        loopViews.append(LoopView(bar: barView4, button: buttonView4))
        
        for loopView in loopViews {
            loopView.bar.wantsLayer = true
            loopView.bar.layer?.cornerRadius = 8
            loopView.button.wantsLayer = true
            loopView.button.layer?.cornerRadius = 8
        }
    }
    
    func updateLoopViews() {
        var i = 0
        for loopView in loopViews {
            let barColor: NSColor
            let buttonColor: NSColor
            switch looperEffect.looperBanks.advanced(by: i).pointee.state {
            case .On:
                barColor = NSColor("4F4F4F")!
                buttonColor = NSColor("8BE24A")!
            case .Off:
                barColor = NSColor("4F4F4F")!
                buttonColor = NSColor("4F4F4F")!
            case .Record:
                barColor = NSColor("E2A74A")!
                buttonColor = NSColor("E2A74A")!
            }
            loopView.bar.layer?.backgroundColor = barColor.cgColor
            loopView.button.layer?.backgroundColor = buttonColor.cgColor
            
            i += 1
        }
    }
    
    @IBAction func barAction(gesture: NSGestureRecognizer) {
        let index = loopViews.map{$0.bar}.index(of: gesture.view!)!
        let bank = looperEffect.looperBanks.advanced(by: index)
        switch bank.pointee.state {
        case .Record: looperEffect.finishRecording()
        case .On, .Off: looperEffect.record(bank)
        }
        updateLoopViews()
    }
    
    @IBAction func buttonAction(gesture: NSGestureRecognizer) {
        let index = loopViews.map{$0.button}.index(of: gesture.view!)!
        let bank = looperEffect.looperBanks.advanced(by: index)
        switch bank.pointee.state {
        case .Record: looperEffect.finishRecording()
        case .On: bank.pointee.state = .Off
        case .Off: bank.pointee.state = .On
        }
        updateLoopViews()
    }
}

extension LooperEffectViewController {
    struct LoopView {
        let bar: NSView
        let button: NSView
        let progress: CALayer
        
        init(bar: NSView, button: NSView) {
            self.bar = bar
            self.button = button
            progress = CALayer()
        }
    }
}

class TapView: NSView {
    var tap: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        acceptsTouchEvents = true
        wantsRestingTouches = true
    }
    
    override func touchesBegan(with event: NSEvent) {
        tap?()
    }
}
