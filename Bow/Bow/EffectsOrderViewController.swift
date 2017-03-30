//
//  EffectsOrderViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 30.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class EffectsOrderViewController: NSViewController {
    @IBOutlet weak var reorderStackView: ReorderStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mock()
    }
    
    func mock() {
        for i in 1..<5 {
            let t = NSTextField()
            t.isEditable = false
            t.stringValue = "xd \(i)"
            reorderStackView.addView(t)
        }
    }
}


class ReorderStackView: NSStackView {
    
    private var draggingState: DraggingState = .none
    
    func addView(_ view: NSView) {
        addView(view, in: .top)
        setupDragging(view: view)
    }
    
    func setupDragging(view: NSView) {
        view.addGestureRecognizer(NSPanGestureRecognizer(target: self, action: #selector(handleDrag)))
    }
    
    func handleDrag(dragGesture: NSPanGestureRecognizer) {
        switch dragGesture.state {
        case .began: beginDragging(view: dragGesture.view!)
        case .changed: updateDragging(dragGesture: dragGesture)
        default: break
        }
    }
    
    func beginDragging(view: NSView) {
        draggingState = .dragging(view: view)
        lastIndex = views.index(of: view)
    }
    
    func updateDragging(dragGesture: NSPanGestureRecognizer) {
        let gestureLocation = dragGesture.location(in: self)
        
        for view in self.views {
            if view.frame.contains(gestureLocation) {
                let index = views.index(of: view)!
                if index != lastIndex {
                    removeView(view)
                    insertView(view, at: index + (index < lastIndex! ? 1 : -1), in: .top)
                }
                lastIndex = index
                return
            }
        }
    }
    
    var lastIndex: Int?
}

extension ReorderStackView {
    enum DraggingState {
        case none
        case dragging(view: NSView)
    }
}
