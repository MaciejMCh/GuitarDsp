//
//  SamplerNodeViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 27.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class SamplerNodeViewController: NSViewController {
    @IBOutlet weak var editButton: NSButton!
    
    var sampler: Sampler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.title = sampler.audioFilePath.components(separatedBy: "/").last!
    }
    
    @IBAction func editAction(_ sender: Any) {
        let samplerViewController = SamplerViewController.make()
        samplerViewController.sampler = sampler
        presentViewControllerAsModalWindow(samplerViewController)
    }
}
