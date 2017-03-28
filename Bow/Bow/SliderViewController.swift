//
//  SliderViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 28.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class SliderViewController: NSViewController {
    var configuration: Configuration!
    
    @IBOutlet weak var sliderSpaceView: NSView!
    @IBOutlet weak var sliderFillView: NSView!
    @IBOutlet weak var scrollDetectingView: ScrollDetectingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearence()
        scrollDetectingView.reportScroll = { (from: CGPoint, to: CGPoint) in
            debugPrint("from:\(from)to:\(to)")
        }
    }
    
    func setupAppearence() {
        sliderSpaceView.wantsLayer = true
        sliderSpaceView.layer!.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
        sliderSpaceView.layer!.cornerRadius = 10
        sliderSpaceView.layer!.masksToBounds = true
        
        sliderFillView.wantsLayer = true
        sliderFillView.layer?.backgroundColor = configuration.mainColor.cgColor
    }
}

extension SliderViewController {
    struct Configuration {
        let mainColor: NSColor
    }
}

extension SliderViewController {
    static func make() -> SliderViewController {
        return NSStoryboard(name: "SliderViewController", bundle: nil).instantiateInitialController() as! SliderViewController
    }
}
