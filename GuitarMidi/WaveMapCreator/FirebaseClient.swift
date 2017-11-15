//
//  FirebaseClient.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 13.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class FirebaseClient {
    init() {
        setupFileSystem()
    }
    
    func sync() {
        syncSamples()
        syncWaveMapConfigurations()
    }
    
    func syncSamples() {
        samplesIndex { firebaseSamples in
            for firebaseSample in firebaseSamples {
                if !FileManager.default.fileExists(atPath: self.filePathForSample(firebaseSample)) {
                    self.downloadSample(firebaseSample)
                }
            }
        }
    }
    
    func syncWaveMapConfigurations() {
        waveMapsIndex { [weak self] waveMapConfigurations in
            guard let wSelf = self else {return}
            for waveMapConfiguration in waveMapConfigurations {
                NSKeyedArchiver.archiveRootObject(waveMapConfiguration.1, toFile: wSelf.filePathForWaveMap(name: waveMapConfiguration.0))
            }
        }
    }
    
    private func setupFileSystem() {
        let waveMapsDirectoryPath = filePathForWaveMap(name: "")
        if !FileManager.default.fileExists(atPath: waveMapsDirectoryPath) {
            try! FileManager.default.createDirectory(atPath: waveMapsDirectoryPath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func waveMapsIndex(completion: @escaping ([(String, JsonObject)]) -> Void) {
        Database.database().reference().child("wave_maps").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            var configurations: [(String, JsonObject)] = []
            for waveMapSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let configuration = waveMapSnapshot.value as! [String: Any]
                let name = waveMapSnapshot.key
                configurations.append((name, configuration))
            }
            completion(configurations)
        }
    }
    
    func saveWaveMap(name: String, configuration: JsonObject) {
        let data = NSKeyedArchiver.archivedData(withRootObject: configuration)
        try! data.write(to: URL(fileURLWithPath: filePathForWaveMap(name: name)))
        Database.database().reference().child("wave_maps/\(name)").updateChildValues(configuration)
    }
    
    private func filePathForWaveMap(name: String) -> String {
        return "\(StorageConstants.waveMapsRootDirectory)/\(name)"
    }
    
    private func downloadSample(_ firebaseSample: FirebaseSample) {
        Storage.storage().reference(forURL: firebaseSample.url.absoluteString).write(toFile: URL(fileURLWithPath: filePathForSample(firebaseSample))) { (url, error) in
            
        }
    }
    
    private func filePathForSample(_ firebaseSample: FirebaseSample) -> String {
        return "\(StorageConstants.samplesRootDirectory)/\(firebaseSample.path)"
    }
    
    private func samplesIndex(completion: @escaping ([FirebaseSample]) -> Void) {
        Database.database().reference().child("samples").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            var firebaseSamples: [FirebaseSample] = []
            for sampleSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let sampleJson = sampleSnapshot.value as! [String: String]
                firebaseSamples.append(FirebaseSample(path: sampleJson["path"] as! String,
                                                      url: URL(string: sampleJson["url"] as! String)!))
            }
            completion(firebaseSamples)
        }
    }
}

struct FirebaseSample {
    let path: String
    let url: URL
}
