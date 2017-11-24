//
//  WaveMapsListViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 21.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class SetupsReferencesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var waveMapsTableView: UITableView!
    @IBOutlet weak var boardsTableView: UITableView!
    
    private var waveMapsReferences: [WaveMapReference]!
    private var boardsNames: [String]!
    private var songsClient: SongsClient!
    private var select: ((SetupReference) -> Void)?
    
    func setup(waveMapsReferences: [WaveMapReference], boardsNames: [String], songsClient: SongsClient, select: @escaping ((SetupReference) -> Void)) {
        self.waveMapsReferences = waveMapsReferences
        self.boardsNames = boardsNames
        self.songsClient = songsClient
        self.select = select
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waveMapsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        boardsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @IBAction func newAction(_ sender: Any?) {
        present(UIAlertController.input(title: "wave map") {[weak self]  in
            self?.songsClient.createWaveMap(.new(name: $0))
            self?.select?(.waveMap(name: $0))
        }, animated: true, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case waveMapsTableView:
            return waveMapsReferences.count
        case boardsTableView:
            return boardsNames.count
        default:
            assert(false)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        switch tableView {
        case waveMapsTableView:
            let waveMapReference = waveMapsReferences[indexPath.row]
            cell.textLabel?.text = waveMapReference.name
        case boardsTableView:
            let boardName = boardsNames[indexPath.row]
            cell.textLabel?.text = boardName
        default:
            assert(false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case waveMapsTableView: select?(.waveMap(name: waveMapsReferences[indexPath.row].name))
        case boardsTableView: select?(.board(name: boardsNames[indexPath.row]))
        default: assert(false)
        }
    }
}
