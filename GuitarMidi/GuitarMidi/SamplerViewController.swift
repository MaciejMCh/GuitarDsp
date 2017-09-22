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
    
    let sampler: Sampler = Sampler(audioFilePath: "/Users/maciejchmielewski/Documents/GuitarDsp/samples/kicks/808-Kicks01.wav")
    
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
}
