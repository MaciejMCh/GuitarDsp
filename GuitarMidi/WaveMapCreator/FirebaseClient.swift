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
    private(set) var samples: [FirebaseSample] = []
    
    func syncSamples() {
        samplesIndex { firebaseSamples in
            self.samples = firebaseSamples
            for firebaseSample in firebaseSamples {
                if !FileManager.default.fileExists(atPath: self.filePathForSample(firebaseSample)) {
                    self.downloadSample(firebaseSample)
                }
            }
        }
    }
    
    private func downloadSample(_ firebaseSample: FirebaseSample) {
        Storage.storage().reference(forURL: firebaseSample.url.absoluteString).write(toFile: URL(fileURLWithPath: filePathForSample(firebaseSample))) { (url, error) in
            
        }
    }
    
    private func filePathForSample(_ firebaseSample: FirebaseSample) -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/samples/" + firebaseSample.path
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
