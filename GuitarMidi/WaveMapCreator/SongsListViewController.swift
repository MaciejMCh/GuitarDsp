//
//  SongsListViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 21.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class SongsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var songsTableView: UITableView!
    @IBOutlet weak var setupsTableView: UITableView!
    
    private let songsClient = SongsClient()
    private var songs: [Song] = []
    private var setups: [SetupReference] = []
    private var selectedSong: Song?
    private var selectedSetup: SetupReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setupsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        songsClient.connect { [weak self] in
            self?.songsUpdated($0)
        }
    }
    
    @IBAction func newSong(_ sender: Any?) {
        present(UIAlertController.input(title: "new song") { [weak self] in
            self?.songsClient.createSong(name: $0)
        }, animated: true, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newWaveMap(_ sender: Any?) {
        guard
            let waveMapsReferences = songsClient.waveMapsReferences,
            let selectedSong = selectedSong,
            let boardsNames = songsClient.boardNames else {return}
        let containedWaveMapNames = selectedSong.setups.flatMap {
            if case .waveMap(let name) = $0 {
                return name
            } else {
                return nil
            }
        }
        let containedBoardsNames = selectedSong.setups.flatMap {
            if case .board(let name) = $0 {
                return name
            } else {
                return nil
            }
        }
        let foreignWaveMapReferences = waveMapsReferences.filter{!containedWaveMapNames.contains($0.name)}
        let foreignBoardsNames = boardsNames.filter{!containedBoardsNames.contains($0)}
        let waveMapsListController = SetupsReferencesViewController.make()
        waveMapsListController.setup(waveMapsReferences: foreignWaveMapReferences,
                                     boardsNames: foreignBoardsNames,
                                     songsClient: songsClient) { [weak self] setupReference in
            self?.songsClient.addSetupToSong(song: selectedSong, setup: setupReference)
            waveMapsListController.dismiss(animated: true, completion: nil)
        }
        present(waveMapsListController, animated: true, completion: nil)
    }
    
    private func songsUpdated(_ songs: [Song]) {
        self.songs = songs
        songsTableView.reloadData()
        
        if let selectedSong = selectedSong {
            for newSong in songs {
                if newSong.name == selectedSong.name {
                    selectSong(newSong)
                }
            }
        }
        
        if let selectedSetup = selectedSetup, let selectedSong = selectedSong {
            for newSetup in selectedSong.setups {
                if newSetup == selectedSetup {
                    selectSetup(newSetup)
                }
            }
        }
    }
    
    private func selectSong(_ song: Song) {
        selectedSong = song
        setups = song.setups
        songsTableView.reloadData()
        setupsTableView.reloadData()
    }
    
    private func selectSetup(_ setup: SetupReference) {
        let selectedSong: Song = self.selectedSong!
        selectedSetup = setup
        setupsTableView.reloadData()
        songsClient.useSetup(Setup(tempo: Float(selectedSong.tempo), reference: setup))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case songsTableView: return songs.count
        case setupsTableView: return setups.count
        default:
            assert(false)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case songsTableView:
            let song = songs[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.selectionStyle = .none
            cell.textLabel?.text = song.name
            cell.textLabel?.font = .boldSystemFont(ofSize: 20)
            cell.backgroundColor = song.name == selectedSong?.name ? .yellow : .white
            return cell
        case setupsTableView:
            let setup = setups[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.selectionStyle = .none
            cell.textLabel?.font = .boldSystemFont(ofSize: 20)
            switch setup {
            case .board(let name):
                cell.textLabel?.text = name
                cell.backgroundColor = .orange
            case .waveMap(let name):
                cell.textLabel?.text = name
                cell.backgroundColor = .green
            }
            
            if let selectedSetup = selectedSetup, selectedSetup == setup {
                cell.backgroundColor = .yellow
            }
            
            return cell
        default:
            assert(false)
            return "" as! UITableViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case songsTableView: selectSong(songs[indexPath.row])
        case setupsTableView: selectSetup(setups[indexPath.row])
        default: assert(false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension UIAlertController {
    static func input(title: String, completion: @escaping (String) -> Void) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        var nameTextFieldReference: UITextField?
        alertController.addTextField { textField in
            nameTextFieldReference = textField
        }
        alertController.addAction(UIAlertAction(title: "continue", style: .default) {_ in
            guard let input = nameTextFieldReference?.text, input.count > 0 else {return}
            completion(input)
        })
        alertController.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        return alertController
    }
}
