//
//  PadViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 25.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class PadContainerViewController: UIViewController {
    private var padMidiOutput: PadMidiOutput!
    private var finish: (() -> Void)!
    
    func setup(padMidiOutput: PadMidiOutput, finish: @escaping () -> Void) {
        self.padMidiOutput = padMidiOutput
        self.finish = finish
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let padViewController = segue.destination as? PadViewController {
            padViewController.padMidiOutput = padMidiOutput
        }
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        finish()
        dismiss(animated: true, completion: nil)
    }
}

class PadViewController: UICollectionViewController {
    var padMidiOutput: PadMidiOutput!
    
    private var visibleCellsCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visibleCellsCount = collectionView?.visibleCells.count
        collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCellsCount ?? 300
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PadButtonCell", for: indexPath) as! PadButtonCell
        cell.onHandler = {[weak self] _ in
            self?.padMidiOutput.onNoteAtIndex(indexPath.row - 40)
        }
        cell.offHandler = {[weak self] _ in
            self?.padMidiOutput.off()
        }
        return cell
    }
}

class PadButtonCell: UICollectionViewCell {
    @IBOutlet weak var padImageView: UIImageView!
    
    var onHandler: ((PadButtonCell) -> ())!
    var offHandler: ((PadButtonCell) -> ())!
    
    private func on() {
        padImageView.image = UIImage(named: "Pad Active")
        onHandler(self)
    }
    
    private func off() {
        padImageView.image = UIImage(named: "Pad Inactive")
        offHandler(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        on()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        off()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        off()
    }
}
