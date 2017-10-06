//
//  Utils.swift
//  NodesMap iOS
//
//  Created by Maciej Chmielewski on 06.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

extension CGRect {
    func moved(by: CGPoint) -> CGRect {
        return CGRect(x: minX + by.x, y: minY + by.y, width: width, height: height)
    }
}

extension CGPoint {
    func distance(to p:CGPoint) -> CGFloat {
        return sqrt(pow(x - p.x, 2) + pow(y - p.y, 2))
    }
}
