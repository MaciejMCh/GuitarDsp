//
//  OscilatorViewController.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

struct WaveShapeViewModel {
    static func all() -> [WaveShapeViewModel] {
        return [WaveShape.sine, WaveShape.square, WaveShape.triangle, WaveShape.circle].map{WaveShapeViewModel(waveShape: $0)}
    }
    
    let waveShape: WaveShape
    
    var image: NSImage {
        switch waveShape {
        case .sine: return NSImage(named: "Sine Shape")!
        case .square: return NSImage(named: "Square Shape")!
        case .triangle: return NSImage(named: "Triangle Shape")!
        case .circle: return NSImage(named: "Circle Shape")!
        }
    }
    
    var name: String {
        switch waveShape {
        case .sine: return "sine"
        case .square: return "square"
        case .triangle: return "triangle"
        case .circle: return "circle"
        }
    }
    
    var tag: Int {
        switch waveShape {
        case .sine: return 0
        case .square: return 1
        case .triangle: return 2
        case .circle: return 3
        }
    }
    
    static func shapeFromTag(_ tag: Int) -> WaveShape {
        switch tag {
        case 0: return .sine
        case 1: return .square
        case 2: return .triangle
        case 3: return .circle
        default: return .sine
        }
    }
}

class OscilatorViewController: NSViewController {
    weak var tuneViewController: VariableViewController!
    weak var volumeViewController: VariableViewController!
    @IBOutlet weak var shapePopupButton: NSPopUpButton!
    
    var oscilator: Oscilator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shapePopupButton.removeAllItems()
        for shapeViewModel in WaveShapeViewModel.all() {
            shapePopupButton.addItem(withTitle: "")
            shapePopupButton.lastItem?.image = shapeViewModel.image
            shapePopupButton.lastItem?.tag = shapeViewModel.tag
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        refreshView()
        
        tuneViewController.variableUpdate = { [weak self] in
            self?.oscilator.tune = $0
        }
        volumeViewController.variableUpdate = { [weak self] in
            self?.oscilator.volume = $0
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let variableViewController = segue.destinationController as? VariableViewController, let identifier = segue.identifier {
            switch identifier {
            case "tune": tuneViewController = variableViewController
            case "volume": volumeViewController = variableViewController
            default: break
            }
        }
    }
    
    private func refreshView() {
        tuneViewController.setVariable(oscilator.tune)
        volumeViewController.setVariable(oscilator.volume)
        shapePopupButton.selectItem(withTag: WaveShapeViewModel(waveShape: oscilator.waveGenerator.waveShape).tag)
    }
    
    @IBAction func viewChanged(_ sender: Any?) {
        oscilator.waveGenerator.waveShape = WaveShapeViewModel.shapeFromTag(shapePopupButton.selectedItem!.tag)
    }
}
