//
//  BoardsClient.swift
//  Bow
//
//  Created by Maciej Chmielewski on 23.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import FirebaseCommunity

class BoardsClient {
    private(set) var boardPrototypes: [(name: String, prototype: BoardPrototype)] = []
    
    func sync() {
        uploadBoards()
        syncBoards()
    }
    
    private func uploadBoards() {
        var boardsJsonObject: [String: Any] = [:]
        for boardPrototypeIdentity in BoardPrototype.all() {
            guard let boardPrototype = BoardPrototype.load(identity: boardPrototypeIdentity) else {return}
            boardsJsonObject[boardPrototypeIdentity.id] = boardPrototype.json()
        }
        Database.database().reference(withPath: "boards").updateChildValues(boardsJsonObject)
    }
    
    private func syncBoards() {
        Database.database().reference(withPath: "boards").observe(.value) {[weak self] (dataSnapshot: DataSnapshot) in
            var boardPrototypes: [(name: String, prototype: BoardPrototype)] = []
            for boardJsonElement in dataSnapshot.value as! [String: JsonObject] {
                let boardPrototype = BoardPrototype(jsonObject: boardJsonElement.value)!
                boardPrototypes.append((boardJsonElement.key, boardPrototype))
            }
            self?.boardPrototypes = boardPrototypes
        }
    }
}
