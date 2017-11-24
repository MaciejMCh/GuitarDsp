//
//  SongsClient.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 21.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Firebase

class SongsClient {
    private(set) var songs: [Song]?
    private(set) var waveMapsReferences: [WaveMapReference]?
    
    init() {
        observeWaveMaps()
    }
    
    func useSetup(_ setup: Setup) {
        Database.database().reference().updateChildValues(["setup" : try! setup.toJSON()])
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


