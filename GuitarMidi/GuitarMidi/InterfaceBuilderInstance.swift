//
//  InterfaceBuilderInstance.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 18.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

protocol InterfaceBuilderInstance {
    static var interfaceFileName: String {get}
}

extension InterfaceBuilderInstance where Self: NSViewController {
    static func make() -> Self {
        return NSStoryboard(name: Self.interfaceFileName, bundle: Bundle(identifier: "com.mch.GuitarMidiKit")!).instantiateInitialController() as! Self
    }
}

extension InterfaceBuilderInstance where Self: NSView {
    static func make() -> Self! {
        var nibContents = NSArray()
        Bundle(identifier: "com.mch.GuitarMidiKit")!.loadNibNamed(Self.interfaceFileName, owner: nil, topLevelObjects: &nibContents)
        for content in nibContents {
            if let me = content as? Self {
                return me
            }
        }
        return nil
    }
}

// MARK: Concrete
extension OscilatorViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "Oscilator"}}
extension TimeFunctionViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "TimeFunctionVariable"}}
extension AmpViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "Amp"}}
extension WaveShaperViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "WaveShaper"}}
extension WaveShaperNodeViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "WaveShaperNode"}}
extension SamplerViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "Sampler"}}
