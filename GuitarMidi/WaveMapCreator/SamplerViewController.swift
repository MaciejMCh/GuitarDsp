//
//  SamplerViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 14.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class SamplerViewController: UIViewController {
    var sampler: Sampler!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let envelopeViewController = segue.destination as? EnvelopeViewController {
            envelopeViewController.envelopeFunction = sampler.volume as! EnvelopeFunction
        }
        if let treeViewController = segue.destination as? TreeViewController {
            treeViewController.tree = FileBrowser(root: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/samples", extensions: StorageConstants.audioFileExtensions, selectAction: { [weak self] file in
                self?.pickSampleFile(path: file.path)
                }, pickAction: { [weak self] file in
                    self?.pickSampleFile(path: file.path)
                }, selectDirectory: {[weak self] directoryPath in
                    if directoryPath.hasSuffix(".sampleset") {
                        self?.pickSampleFile(path: directoryPath)
                    }
            }).makeTree()
        }
    }
    
    private func pickSampleFile(path: String) {
        sampler.sampleFilePath = path
        sampler.on()
    }
}
