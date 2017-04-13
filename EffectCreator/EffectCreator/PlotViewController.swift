//
//  PlotViewController.swift
//  EffectCreator
//
//  Created by Maciej Chmielewski on 12.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class PlotViewController: NSViewController {
    static var me: PlotViewController!
    private static var data: [String: [Float]] = [:]
    static func record(serie: String, value: Float) {
        if !data.keys.contains(serie) {
            data[serie] = []
        }
        data[serie]?.append(value)
    }
    
    @IBOutlet weak var stackView: NSStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PlotViewController.me = self
    }
    
    func draw() {
        for entity in PlotViewController.data.enumerated().map({$0.element}) {
            let plotView = PlotView()
            plotView.values = entity.value
            stackView.addView(plotView, in: .top)
        }
    }
    
}
