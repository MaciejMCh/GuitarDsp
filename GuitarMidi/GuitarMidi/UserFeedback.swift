//
//  UserFeedback.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 16.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

struct UserFeedback {
    static func displayMessage(_ message: String) {
        messageDisplay?(message)
    }
    
    static var messageDisplay: ((String) -> Void)?
}
