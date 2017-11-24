//
//  FirebaseClient.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 16.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import FirebaseCommunity

public class FirebaseClient {
    public init() {
        FirebaseApp.configure()
    }
    
    public func sync() {
        syncSamples()
    }
    
    private func syncSamples() {
        Database.database().reference(withPath: "samples").observeSingleEvent(of: .value) { (dataSnapshot: DataSnapshot) in
            let samplesRecordsJson = dataSnapshot.value as? [String: String] ?? [:]
            let serverSamplesRecords: [(id: String, path: String)] = samplesRecordsJson.map{(id: $0.key as! String, path: $0.value as! String)}
            let serverSamplesPaths = serverSamplesRecords.map{$0.path}
            var newServerSamplesRecords = serverSamplesRecords
            
            let localSamplesFilesPaths = self.indexSamples()
            let totalUploadsCount = localSamplesFilesPaths.count - serverSamplesRecords.count
            var remainingUploadsCount = totalUploadsCount
            if totalUploadsCount > 0 {
                UserFeedback.displayMessage("uploading (\(totalUploadsCount)/\(totalUploadsCount))")
            }
            for localSampleFilePath in localSamplesFilesPaths {
                let localSamplePath = localSampleFilePath.components(separatedBy: "samples/").last!
                if serverSamplesPaths.contains(localSamplePath) {continue}
                let newSampleRecord = (id: NSUUID().uuidString, path: localSamplePath)
                newServerSamplesRecords.append(newSampleRecord)
                Storage.storage().reference(withPath: "samples/\(newSampleRecord.id)").putFile(from: URL(fileURLWithPath: localSampleFilePath), metadata: nil, completion: { (_, _) in
                    remainingUploadsCount -= 1
                    switch remainingUploadsCount {
                    case 0: UserFeedback.displayMessage("uploading done")
                    default: UserFeedback.displayMessage("uploading (\(remainingUploadsCount)/\(totalUploadsCount))")
                    }
                })
            }
            
            var newSamplesRecordsJson: [String: String] = [:]
            for newServerSamplesRecord in newServerSamplesRecords {
                newSamplesRecordsJson[newServerSamplesRecord.id] = newServerSamplesRecord.path
            }
            Database.database().reference(withPath: "samples").updateChildValues(newSamplesRecordsJson)
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
                if let fileExtension = directoryElement.components(separatedBy: ".").last, StorageConstants.storableFileExtensions.contains(fileExtension) {
                    filePaths.append(directoryElementPath)
                }
            }
        }
        return filePaths
    }
}
