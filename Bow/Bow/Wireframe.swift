//
//  Wireframe.swift
//  Bow
//
//  Created by Maciej Chmielewski on 29.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

protocol InterfaceBuilderInstance {
    static var interfaceFileName: String {get}
}

extension InterfaceBuilderInstance where Self: NSViewController {
    static func make() -> Self {
        return NSStoryboard(name: Self.interfaceFileName, bundle: nil).instantiateInitialController() as! Self
    }
}

extension InterfaceBuilderInstance where Self: NSView {
    static func make() -> Self! {
        var nibContents = NSArray()
        Bundle(for: Self.self).loadNibNamed(Self.interfaceFileName, owner: nil, topLevelObjects: &nibContents)
        for content in nibContents {
            if let me = content as? Self {
                return me
            }
        }
        return nil
    }
}

// MARK: Concrete
extension SliderViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "SliderViewController"}}
extension EffectViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "EffectViewController"}}
extension BoardViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "BoardViewController"}}
extension EffectsOrderViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "EffectsOrderViewController"}}
extension EffectIdentityView: InterfaceBuilderInstance {static var interfaceFileName: String {return "EffectIdentityView"}}
extension SearchViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "SearchViewController"}}
extension TagPickerController: InterfaceBuilderInstance {static var interfaceFileName: String {return "TagPickerController"}}
extension LooperEffectViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "LooperViewController"}}
extension SetupViewController: InterfaceBuilderInstance {static var interfaceFileName: String {return "SetupViewController"}}
extension ChannelPlayerTileController: InterfaceBuilderInstance {static var interfaceFileName: String {return "ChannelPlayerTile"}}
