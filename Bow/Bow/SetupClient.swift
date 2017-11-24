//
//  SetupClient.swift
//  Bow
//
//  Created by Maciej Chmielewski on 23.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import FirebaseCommunity
import GuitarMidi
import JSONCodable

enum SetupInstance {
    case board(name: String)
    case waveMap(WaveMapReference)
}

class SetupClient {
    private let boardsClient = BoardsClient()
    private var waveMapsReferences: [WaveMapReference] = []
    
    init() {
        syncWaveMaps()
        syncBoards()
    }
    
    func sync(update: @escaping (SetupInstance) -> Void ) -> DatabaseHandle {
        return Database.database().reference(withPath: "setup").observe(.value) { [weak self] (snapshot: DataSnapshot) in
            guard let wSelf = self else {return}
            let setup = try! Setup(object: snapshot.value as! JSONObject)
            switch setup.reference {
            case .board(let name): update(.board(name: name))
            case .waveMap(let name):
                for waveMapReference in wSelf.waveMapsReferences {
                    if waveMapReference.name == name {
                        update(.waveMap(waveMapReference))
                        return
                    }
                }
            }
        }
    }
    
    private func syncBoards() {
        boardsClient.sync()
    }
    
    private func syncWaveMaps() {
        Database.database().reference(withPath: "wave_maps").observe(.value) { [weak self] (snapshot: DataSnapshot) in
            var waveMapsReferences: [WaveMapReference] = []
            for waveMapSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let configuration = waveMapSnapshot.value as! [String: Any]
                let name = waveMapSnapshot.key
                waveMapsReferences.append(WaveMapReference(name: name, configuration: configuration))
            }
            self?.waveMapsReferences = waveMapsReferences
        }
    }
}

