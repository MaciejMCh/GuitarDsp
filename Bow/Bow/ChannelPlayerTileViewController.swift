//
//  ChannelPlayerTileViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 27.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarMidi

class ChannelPlayerTileController: NSViewController {
    var channelPlayerEffect: ChannelPlayerEffect!
    var bass808: Bass808!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    @IBAction func editAction(sender: Any?) {
        let channelPlayerController = NSStoryboard(name: "Bass808", bundle: Bundle(identifier: "org.cocoapods.GuitarMidi")!).instantiateInitialController() as! Bass808ViewController
        channelPlayerController.bass808 = bass808
        presentViewControllerAsModalWindow(channelPlayerController)
    }
}
