//
//  OutputMonitorViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 18.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit
class OutputMonitorViewController: UIViewController {
    @IBOutlet weak var graphView: GraphView!
    var output: SignalOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let offset = 1000000
        for i in 0..<offset {
            output.next(i)
        }
        
        var signal: [Double] = []
        for i in 0..<10000 {
            signal.append(output.next(i))
        }
        graphView.values = signal
    }
    
}
