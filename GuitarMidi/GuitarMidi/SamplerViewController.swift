//
//  SamplerViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 22.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarDsp

class SamplerViewController: NSViewController {
    weak var fileTreeViewController: TreeViewController!
    @IBOutlet weak var waveView: WaveView!
    @IBOutlet weak var waveViewWidthConstraint: NSLayoutConstraint!
    
    var waveSublayers: [CALayer] = []
    
    let sampler: Sampler = Sampler(audioFilePath: "/Users/maciejchmielewski/Documents/GuitarDsp/samples/kicks/808-Kicks01.wav", samplingSettings: AudioInterface.shared().samplingSettings)
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let treeViewController = segue.destinationController as? TreeViewController {
            fileTreeViewController = treeViewController
            treeViewController.tree = FileBrowser.samples(selectAction: { [weak self] file in
                self?.pickAudioFile(path: file.path)
            }, pickAction: { [weak self] file in
                self?.pickAudioFile(path: file.path)
            }).makeTree()
        }
        
        if let envelopeViewController = segue.destinationController as? EnvelopeViewController {
            envelopeViewController.envelopeFunction = sampler.volume as! EnvelopeFunction
            envelopeViewController.envelopeUpdate = { [weak self] in
                self?.updateViews()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waveView.wantsLayer = true
    }
    
    private func updateViews() {
        for waveSublayer in waveSublayers {
            waveSublayer.removeFromSuperlayer()
        }
        waveSublayers.removeAll()
        
        if let volumeEnvelope = sampler.volume as? EnvelopeFunction {
            drawVolumeEnvelope(envelope: volumeEnvelope)
        }
        drawTimeAxis()
    }
    
    private func drawTimeAxis() {
        let length = Int(waveView.frame.width)
        let height = Int(waveView.frame.height)
        let spacing = 300
        let indicatorsCount = length / spacing
        let color = NSColor.red.cgColor
        
        let linesPath = NSBezierPath()
        for i in 1..<indicatorsCount + 1 {
            let x = CGFloat(spacing * i)
            let progress = Double(x) / Double(length)
            let timeInSeconds = progress * Double(sampler.audioFile.duration)
            
            linesPath.move(to: NSPoint(x: x, y: 0))
            linesPath.line(to: NSPoint(x: x, y: CGFloat(height)))
            
            let textLayer = CATextLayer()
            textLayer.fontSize = 15
            textLayer.contentsScale = 4
            textLayer.frame = CGRect(x: x - 100, y: 0, width: 100, height: 100)
            textLayer.alignmentMode = kCAAlignmentRight
            textLayer.string = String(format: "%.4fs", timeInSeconds)
            textLayer.foregroundColor = color
            waveView.layer?.addSublayer(textLayer)
            waveSublayers.append(textLayer)
        }
        
        let layer = CAShapeLayer()
        waveSublayers.append(layer)
        layer.path = linesPath.cgPath
        layer.strokeColor = color
        waveView.layer?.addSublayer(layer)
    }
    
    private func drawVolumeEnvelope(envelope: EnvelopeFunction) {
        let length = Int(waveView.frame.width)
        let height = 100.0
        
        let envelopePath = NSBezierPath()
        envelopePath.move(to: .init(x: 0, y: 0))
        let drawingEnvelopeFunction = envelope.makeClone()
        
        drawingEnvelopeFunction.duration = Double(length / 2)
        drawingEnvelopeFunction.on()
        for i in 0..<length {
            envelopePath.line(to: .init(x: CGFloat(i), y: CGFloat(height) * CGFloat(drawingEnvelopeFunction.nextSample())))
            if i == length / 2 {
                drawingEnvelopeFunction.off()
            }
        }
        
        let layer = CAShapeLayer()
        waveSublayers.append(layer)
        layer.path = envelopePath.cgPath
        layer.fillColor = NSColor.blue.withAlphaComponent(0.5).cgColor
        layer.backgroundColor = NSColor.red.cgColor
        waveView.layer?.addSublayer(layer)
    }
    
    private func pickAudioFile(path: String) {
        sampler.audioFilePath = path
        waveView.values = sampler.audioFile.samples.map{Double($0)}
    }
    
    enum Zooming {
        case none
        case pending(initialWidth: CGFloat)
    }
    var state = Zooming.none
    
    @IBAction func zoomAction(gesture: NSMagnificationGestureRecognizer) {
        switch gesture.state {
        case .began: state = .pending(initialWidth: waveViewWidthConstraint.constant)
        case .changed:
            if case .pending(let initialWidth) = state {
                waveViewWidthConstraint.constant = max(100, initialWidth * (gesture.magnification + 1))
                waveView.needsDisplay = true
                updateViews()
            }
        default: break
        }
    }
}

extension NSBezierPath {
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveToBezierPathElement: path.move(to: points[0])
            case .lineToBezierPathElement: path.addLine(to: points[0])
            case .curveToBezierPathElement: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePathBezierPathElement: path.closeSubpath()
            }
        }
        return path
    }
}
