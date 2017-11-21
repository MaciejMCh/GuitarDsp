//
//  InterfaceBuilderInstance.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 17.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

protocol InterfaceBuilderInstance {
    static var interfaceBuilderFileName: String {get}
}

extension InterfaceBuilderInstance where Self: UIView {
    static func make() -> Self {
        for nibContent in UINib(nibName: Self.interfaceBuilderFileName, bundle: nil).instantiate(withOwner: nil, options: nil) {
            if let me = nibContent as? Self {
                return me
            }
        }
        
        assert(false)
        let none: Self! = nil
        return none
    }
}

extension InterfaceBuilderInstance where Self: UIViewController {
    static func make() -> Self {
        return UIStoryboard(name: Self.interfaceBuilderFileName, bundle: nil).instantiateInitialViewController() as! Self
    }
}

// MARK: Concretes
extension OscilatorViewController: InterfaceBuilderInstance {static let interfaceBuilderFileName = "Oscilator"}
extension WaveShaperViewController: InterfaceBuilderInstance {static let interfaceBuilderFileName = "WaveShaper"}
extension DecadeViewController: InterfaceBuilderInstance {static let interfaceBuilderFileName = "Decade"}
extension OutputMonitorViewController: InterfaceBuilderInstance {static let interfaceBuilderFileName = "Monitor"}
extension PadContainerViewController: InterfaceBuilderInstance {static let interfaceBuilderFileName = "PadContainer"}
extension ReverbViewController: InterfaceBuilderInstance {static let interfaceBuilderFileName = "Reverb"}
extension PhaserViewController: InterfaceBuilderInstance {static let interfaceBuilderFileName = "Phaser"}
extension SongsListViewController: InterfaceBuilderInstance {static let interfaceBuilderFileName = "Songs"}
extension WaveMapsListViewController: InterfaceBuilderInstance {static let interfaceBuilderFileName = "WaveMapsList"}
