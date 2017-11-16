//
//  FirebaseClient.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 16.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import FirebaseCommunity

class FirebaseClient {
    init() {
        FirebaseApp.configure()
    }
    
    func sync() {
        syncSamples()
    }
    
    private func syncSamples() {
        for samplePath in indexSamples() {
            let sampleName = samplePath.components(separatedBy: "samples/").last!
            Storage.storage().reference(withPath: sampleName).getMetadata { (metadata, error) in
                if metadata == nil {
                    let sampleId = UUID().uuidString
                    Storage.storage().reference(withPath: "samples/\(sampleId)").putFile(from: URL(fileURLWithPath: samplePath))
                    Database.database().reference(withPath: "samples").updateChildValues([sampleId: sampleName])
                }
            }
        }
    }
    
    private func indexSamples() -> [String] {
        return files(path: StorageConstants.samplesRootDirectory)
    }
    
    private func files(path: String) -> [String] {
        var filePaths: [String] = []
        for directoryElement in try! FileManager.default.contentsOfDirectory(atPath: path) {
            let directoryElementPath = "\(path)/\(directoryElement)"
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: directoryElementPath, isDirectory: &isDirectory)
            if isDirectory.boolValue {
                filePaths.append(contentsOf: files(path: directoryElementPath))
            } else {
                if let fileExtension = directoryElement.components(separatedBy: ".").last, StorageConstants.audioFileExtensions.contains(fileExtension) {
                    filePaths.append(directoryElementPath)
                }
            }
        }
        return filePaths
    }
}
