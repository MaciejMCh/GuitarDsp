//
//  WaveMapsListViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 21.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class WaveMapsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private var waveMapsReferences: [WaveMapReference]!
    private var songsClient: SongsClient!
    private var select: ((WaveMapReference) -> Void)?
    
    func setup(waveMapsReferences: [WaveMapReference], songsClient: SongsClient, select: @escaping ((WaveMapReference) -> Void)) {
        self.waveMapsReferences = waveMapsReferences
        self.songsClient = songsClient
        self.select = select
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @IBAction func newAction(_ sender: Any?) {
        present(UIAlertController.input(title: "wave map") {[weak self]  in
            self?.songsClient.createWaveMap(.new(name: $0))
            self?.select?(.new(name: $0))
        }, animated: true, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waveMapsReferences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let waveMapReference = waveMapsReferences[indexPath.row]
        cell.textLabel?.text = waveMapReference.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        select?(waveMapsReferences[indexPath.row])
    }
}
