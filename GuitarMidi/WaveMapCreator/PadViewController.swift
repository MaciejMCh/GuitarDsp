//
//  PadViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 25.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class PadViewController: UITableViewController {
    var padMidiOutput: PadMidiOutput!
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PadButtonCell") as! PadButtonCell
        cell.onHandler = {[weak self] in
            tableView.indexPath(for: $0)
            self?.padMidiOutput.onNoteAtIndex(tableView.indexPath(for: $0)!.row - 20)
        }
        cell.offHandler = {[weak self] _ in
            self?.padMidiOutput.off()
        }
        return cell
    }
}

class PadButtonCell: UITableViewCell {
    var onHandler: ((PadButtonCell) -> ())!
    var offHandler: ((PadButtonCell) -> ())!
    
    @IBAction func on(_ sender: Any?) {
        onHandler(self)
    }
    
    @IBAction func off(_ sender: Any?) {
        offHandler(self)
    }
}
