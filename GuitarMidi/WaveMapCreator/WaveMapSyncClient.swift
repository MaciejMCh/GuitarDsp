//
//  WaveMapSyncClient.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 24.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Firebase

struct WaveMapSyncClient {
    func sync(reference: WaveMapReference) {
        Database.database().reference(withPath: "wave_maps").updateChildValues([reference.name: reference.configuration])
    }
}
