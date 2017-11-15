//
//  StorageConstants.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 15.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

struct StorageConstants {
    static let rootDirectory: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    static let samplesRootDirectory: String = rootDirectory + "/samples"
    static let waveMapsRootDirectory: String = rootDirectory + "/wave_maps"
}
