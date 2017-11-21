//
//  PadViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 25.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

extension PadContainerViewController {
    enum State {
        case notTouched
        case touched(point: CGPoint)
        case doubleTouched(first: CGPoint, second: CGPoint)
    }
}

class PadContainerViewController: UIViewController {
    @IBOutlet weak var touchesView: TouchView!
    weak var padViewController: PadViewController!
    
    private let noteIndexCorrection = -40
    private var padMidiOutput: PadMidiOutput!
    private var finish: (() -> Void)!
    private var state: State = .notTouched
    
    func setup(padMidiOutput: PadMidiOutput, finish: @escaping () -> Void) {
        self.padMidiOutput = padMidiOutput
        self.finish = finish
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchesView.on = {[weak self] point in
            guard let wSelf = self else {return}
            
            switch wSelf.state {
            case .notTouched:
                wSelf.on(point: point)
                wSelf.state = .touched(point: point)
            case .touched(let firstTouchPoint):
                wSelf.slide(point: point)
                wSelf.state = .doubleTouched(first: firstTouchPoint, second: point)
            case .doubleTouched:
                break
            }
        }
        
        touchesView.off = {[weak self] point in
            guard let wSelf = self else {return}
            
            switch wSelf.state {
            case .notTouched:
                break
            case .touched:
                wSelf.off()
                wSelf.state = .notTouched
            case .doubleTouched(let first, let second):
                let offedPoint = point.closest(points: [first, second])!
                if offedPoint.isSame(first) {
                    wSelf.state = .touched(point: second)
                    wSelf.slide(point: second)
                } else if offedPoint.isSame(second) {
                    wSelf.state = .touched(point: first)
                    wSelf.slide(point: first)
                } else {
                    assert(false)
                }
            }
        }
        
        touchesView.move = {[weak self] point in
            guard let wSelf = self else {return}
            
            switch wSelf.state {
            case .touched:
                wSelf.slide(point: point)
                wSelf.state = .touched(point: point)
            case .doubleTouched(let first, let second):
                let closerPoint = point.closest(points: [first, second])!
                if closerPoint.isSame(second) {
                    wSelf.slide(point: point)
                    wSelf.state = .doubleTouched(first: first, second: point)
                } else {
                    wSelf.state = .doubleTouched(first: point, second: second)
                }
            case .notTouched:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let padViewController = segue.destination as? PadViewController {
            self.padViewController = padViewController
        }
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        finish()
        dismiss(animated: true, completion: nil)
    }
    
    private func on(point: CGPoint) {
        for cell in padViewController.collectionView?.visibleCells as! [PadButtonCell] {
            if cell.frame.contains(point) {
                highlightCell(cell)
            } else {
                lowlightCell(cell)
            }
        }
        
        let index = indexForPoint(point)
        padMidiOutput.onNoteAtIndex(index + noteIndexCorrection)
    }
    
    
    private var lastHighlightedIndex: Int?
    private func slide(point: CGPoint) {
        for cell in padViewController.collectionView?.visibleCells as! [PadButtonCell] {
            if cell.frame.contains(point) {
                highlightCell(cell)
            } else {
                lowlightCell(cell)
            }
        }
        
        let index = indexForPoint(point)
        if index != lastHighlightedIndex {
            padMidiOutput.slideToIndex(index + noteIndexCorrection)
            lastHighlightedIndex = index
        }
    }
    
    private func off() {
        for cell in padViewController.collectionView?.visibleCells as! [PadButtonCell] {
            lowlightCell(cell)
        }
        padMidiOutput.off()
    }
    
    private func highlightCell(_ cell: PadButtonCell) {
        cell.padImageView.image = UIImage(named: "Pad Active")
    }
    
    private func lowlightCell(_ cell: PadButtonCell) {
        cell.padImageView.image = UIImage(named: "Pad Inactive")
    }
    
    private func indexForPoint(_ point: CGPoint) -> Int {
        let cellSize: CGFloat = 50
        let rowLength = Int(floor(Double(padViewController.view.frame.width) / Double(cellSize)))
        
        let xPosition = Int(point.x / cellSize)
        let yPosition = Int(point.y / cellSize)
        
        return (rowLength * yPosition) + xPosition
    }
}

class PadViewController: UICollectionViewController {
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
        return cell
    }
}

class TouchView: UIView {
    var on: ((CGPoint) -> Void)?
    var off: ((CGPoint) -> Void)?
    var move: ((CGPoint) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isMultipleTouchEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        on?(touches.first!.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        move?(touches.first!.location(in: self))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        off?(touches.first!.location(in: self))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        off?(touches.first!.location(in: self))
    }
}

class PadButtonCell: UICollectionViewCell {
    @IBOutlet weak var padImageView: UIImageView!
}
