//
//  NodesListViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 25.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit
import GuitarDsp

class NodesListViewController: UITableViewController {
    let samplingSettings = AudioInterface.shared().samplingSettings
    
    private lazy var allNodeModels: [WaveNode] = {
        [
            Oscilator(samplingSettings: self.samplingSettings)
        ]
    }()
    
    var addNode: ((WaveNode) -> ())?
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNodeModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = allNodeModels[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addNode?(allNodeModels[indexPath.row].makeClone(samplingSettings: samplingSettings))
    }
}

extension WaveNode {
    var name: String {
        switch self {
        case is Oscilator: return "oscilator"
        default:
            assert(false)
            return "xd"
        }
    }
    
    func makeClone(samplingSettings: SamplingSettings) -> WaveNode {
        switch self {
        case is Oscilator: return Oscilator(samplingSettings: samplingSettings)
        default:
            return "xd" as! WaveNode
        }
    }
}
