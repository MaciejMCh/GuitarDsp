//
//  MathUtils.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 09.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

public let halfToneToScale: (Double) -> Double = {pow(2, $0 / 12)}
