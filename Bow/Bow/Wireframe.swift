//
//  Wireframe.swift
//  Bow
//
//  Created by Maciej Chmielewski on 29.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

protocol StoryboardInstance {
    static var storyboardName: String {get}
}

extension StoryboardInstance where Self: NSViewController {
    static func make() -> Self {
        return NSStoryboard(name: Self.storyboardName, bundle: nil).instantiateInitialController() as! Self
    }
}

// MARK: Concrete
extension SliderViewController: StoryboardInstance {static var storyboardName: String {return "SliderViewController"}}
extension EffectViewController: StoryboardInstance {static var storyboardName: String {return "EffectViewController"}}
extension BoardViewController: StoryboardInstance {static var storyboardName: String {return "BoardViewController"}}
extension EffectsOrderViewController: StoryboardInstance {static var storyboardName: String {return "EffectsOrderViewController"}}
