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
        return [WaveShape.sine, .square, .triangle, .sawtooth, .circle].map{WaveShapeViewModel(waveShape: $0)}
    }
    
    let waveShape: WaveShape
    
    var image: NSImage {
        let bundle = Bundle(for: ChannelPlayerEffect)
        switch waveShape {
        case .sine: return bundle.image(forResource: "Sine Shape")!
        case .square: return bundle.image(forResource: "Square Shape")!
        case .triangle: return bundle.image(forResource: "Triangle Shape")!
        case .sawtooth: return bundle.image(forResource: "Sawtooth Shape")!
        case .circle: return bundle.image(forResource: "Circle Shape")!
        }
    }
    
    var name: String {
        switch waveShape {
        case .sine: return "sine"
        case .square: return "square"
        case .triangle: return "triangle"
        case .sawtooth: return "sawtooth"
        case .circle: return "circle"
        }
    }
    
    static func tag(waveShape: WaveShape) -> Int {
        return all().map{$0.waveShape}.index(of: waveShape)!
    }
    
    static func shapeFromTag(_ tag: Int) -> WaveShape {
        return all()[tag].waveShape
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
            shapePopupButton.lastItem?.tag = WaveShapeViewModel.tag(waveShape: shapeViewModel.waveShape)
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
        shapePopupButton.selectItem(withTag: WaveShapeViewModel.tag(waveShape: oscilator.waveGenerator.waveShape))
    }
    
    @IBAction func viewChanged(_ sender: Any?) {
        oscilator.waveGenerator.waveShape = WaveShapeViewModel.shapeFromTag(shapePopupButton.selectedItem!.tag)
    }
}
