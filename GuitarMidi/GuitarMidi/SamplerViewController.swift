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
            }
        default: break
        }
    }
}
