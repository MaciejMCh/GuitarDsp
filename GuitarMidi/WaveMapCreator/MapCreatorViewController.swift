//
//  MapCreatorViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 22.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit
import NodesMap
import GuitarDsp

class MapCreatorViewController: UIViewController {
    var waveMap: WaveMap!
    var padMidiOutput: PadMidiOutput!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapController = segue.destination as? MapViewController {
            mapController.map = waveMap.map
        }
        if let addNodesController = segue.destination as? NodesListViewController {
            addNodesController.addNode = {
                self.waveMap.addWaveNode(waveNode: $0)
            }
        }
        if let padController = segue.destination as? PadViewController {
            padController.padMidiOutput = padMidiOutput
        }
    }
}
