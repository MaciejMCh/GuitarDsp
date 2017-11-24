//
//  StorageConstants.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 15.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

struct StorageConstants {
    #if os(OSX)
    static let rootDirectory: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/GuitarDsp"
    #elseif os(iOS)
    static let rootDirectory: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    #endif
    static let samplesRootDirectory: String = rootDirectory + "/samples"
    static let waveMapsRootDirectory: String = rootDirectory + "/wave_maps"
    static let audioFileExtensions = ["wav", "mp3"]
    static let storableFileExtensions = ["wav", "json", "mp3"]
}
