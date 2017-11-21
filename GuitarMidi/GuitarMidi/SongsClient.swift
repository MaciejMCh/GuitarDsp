//
//  SongsClient.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 21.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Firebase
import JSONCodable

enum SetupReference: JSONCodable {
    case waveMap(name: String)
    case board(name: String)
    
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        switch try decoder.decode("type") as String {
        case "wave_map": self = .waveMap(name: try decoder.decode("name"))
        case "board": self = .board(name: try decoder.decode("name"))
        default: throw NSError()
        }
    }
    
    func toJSON() throws -> Any {
        switch self {
        case .board(let name): return ["type": "board", "name": name]
        case .waveMap(let name): return ["type": "wave_map", "name": name]
        }
    }
    
    static func ==(lhs: SetupReference, rhs: SetupReference) -> Bool {
        switch (lhs, rhs) {
        case (.waveMap(let lhsName), .waveMap(let rhsName)): return lhsName == rhsName
        case (.board(let lhsName), .board(let rhsName)): return lhsName == rhsName
        default: return false
        }
    }
}

struct Song: JSONCodable {
    let name: String
    let tempo: Double
    let setups: [SetupReference]
    
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        name = try decoder.decode("name")
        tempo = try decoder.decode("tempo")
        setups = try decoder.decode("setups")
    }
    
    func toJSON() throws -> Any {
        return ["name": name,
                "tempo": tempo,
                "setups": try setups.toJSON()]
    }
    
    init(name: String, tempo: Double, setups: [SetupReference]) {
        self.name = name
        self.tempo = tempo
        self.setups = setups
    }
    
    static func new(name: String) -> Song {
        return Song(name: name, tempo: 100, setups: [])
    }
}

class SongsClient {
    private(set) var songs: [Song]?
    private(set) var waveMapsReferences: [WaveMapReference]?
    
    init() {
        observeWaveMaps()
    }
    
    func connect(refresh: @escaping ([Song]) -> Void) {
        Database.database().reference().child("songs").observe(.value) { [weak self] (snapshot: DataSnapshot) in
            var songs: [Song] = []
            for songJsonObject in snapshot.value as? [String: [String: Any]] ?? [:] {
                let song = try! Song(object: songJsonObject.value)
                songs.append(song)
            }
            self?.songs = songs
            refresh(songs)
        }
    }
    
    func createSong(name: String) {
        guard let existingSongs = songs else {return}
        let existingSongsNames = existingSongs.map{$0.name}
        var newSongName = name
        while existingSongsNames.contains(newSongName) {
            newSongName = newSongName + "*"
        }
        Database.database().reference(withPath: "songs").updateChildValues([name: try! Song.new(name: name).toJSON()])
    }
    
    func createWaveMap(_ waveMapReference: WaveMapReference) {
        Database.database().reference(withPath: "wave_maps").updateChildValues([waveMapReference.name: waveMapReference.configuration])
    }
    
    func addSetupToSong(song: Song, setup: SetupReference) {
        var newSetups = song.setups
        newSetups.append(setup)
        let newSong = Song(name: song.name, tempo: song.tempo, setups: newSetups)
        Database.database().reference(withPath: "songs").updateChildValues([newSong.name: try! newSong.toJSON()])
    }
    
    private func observeWaveMaps() {
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


