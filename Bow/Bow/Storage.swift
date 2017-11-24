//
//  Storage.swift
//  Bow
//
//  Created by Maciej Chmielewski on 31.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import GuitarDsp
import JSONCodable

typealias JsonObject = [String: Any]
typealias JsonArray = [JsonObject]

protocol JsonObjectRepresentable {
    static var typeName: String {get}
    init?(jsonObject: JsonObject)
    func json() -> JsonObject
}

struct Storage {
    let typeName: String
    var storagePath: String {
        return "\(NSHomeDirectory())/Documents/GuitarDsp/\(typeName)"
    }
    
    private func filePath(identity: Identity) -> String {
        return "\(storagePath)/\(identity.id)"
    }
    
    func save(json: JsonObject, identity: Identity) {
        NSKeyedArchiver.archiveRootObject(json, toFile: filePath(identity: identity))
    }
    
    func load(identity: Identity) -> JsonObject? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: filePath(identity: identity)) as? JsonObject
    }
}

extension Storage {
    struct Identity {
        let id: String
    }
}

protocol BasicStorable {
    func make() -> JsonObjectRepresentable?
    func update()
}

enum StorableOrigin {
    case selfMade(identity: Storage.Identity)
    case child(parent: BasicStorable)
    case orphan
}

struct Storable<T: JsonObjectRepresentable>: BasicStorable {
    let origin: StorableOrigin
    var jsonRepresentable: T
    
    func update() {
        switch origin {
        case .selfMade(let identity):
            Storage(typeName: T.typeName).save(json: jsonRepresentable.json(), identity: identity)
        case .child(let parent): parent.update()
        case .orphan: break
        }
    }
    
    func make() -> JsonObjectRepresentable? {
        switch origin {
        case .selfMade(let identity):
            guard let json = Storage(typeName: T.typeName).load(identity: identity) else {return nil}
            return T.init(jsonObject: json)
        default: return nil
        }
    }
    
    func makeConcrete() -> T? {
        return make() as? T
    }
}

extension JsonObjectRepresentable {
    static func all() -> [Storage.Identity] {
        let objectsNames: [String]
        do {
            objectsNames = try FileManager.default.contentsOfDirectory(atPath: Storage(typeName: typeName).storagePath)
        } catch (_) {
            objectsNames = []
        }
        return objectsNames.filter{!$0.hasPrefix(".")}.map{Storage.Identity(id: $0)}
    }
    
    static func load(identity: Storage.Identity) -> Self? {
        guard let json = Storage(typeName: typeName).load(identity: identity) else {return nil}
        guard let model = Self.init(jsonObject: json) else {return nil}
        return model
    }
}
