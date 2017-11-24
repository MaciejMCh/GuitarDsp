//
//  FirebaseModels.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 22.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import JSONCodable

public struct WaveMapReference {
    public let name: String
    public let configuration: [String: Any]
    
    public init(name: String, configuration: [String: Any]) {
        self.name = name
        self.configuration = configuration
    }
    
    static func new(name: String) -> WaveMapReference {
        return WaveMapReference(name: name, configuration: WaveMap.zeroConfiguration())
    }
}

public struct FirebaseSample {
    public let path: String
    public let url: URL
}

public struct Setup: JSONCodable {
    public let tempo: Float
    public let reference: SetupReference
    
    init(tempo: Float, reference: SetupReference) {
        self.tempo = tempo
        self.reference = reference
    }
    
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        tempo = try decoder.decode("tempo")
        reference = try decoder.decode("reference")
    }
    
    public func toJSON() throws -> Any {
        return ["tempo": tempo,
                "reference": try reference.toJSON()]
    }
}

public enum SetupReference: JSONCodable {
    case waveMap(name: String)
    case board(name: String)
    
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        switch try decoder.decode("type") as String {
        case "wave_map": self = .waveMap(name: try decoder.decode("name"))
        case "board": self = .board(name: try decoder.decode("name"))
        default: throw NSError()
        }
    }
    
    public func toJSON() throws -> Any {
        switch self {
        case .board(let name): return ["type": "board", "name": name]
        case .waveMap(let name): return ["type": "wave_map", "name": name]
        }
    }
    
    static func ==(lhs: SetupReference, rhs: SetupReference) -> Bool {
        switch (lhs, rhs) {
        case (.waveMap(let lhsName), .waveMap(let rhsName)): return lhsName == rhsName
        case (.board(let lhsName), .board(let rhsName)): return lhsName == rhsName
        default: return false
        }
    }
}

public struct Song: JSONCodable {
    public let name: String
    public let tempo: Double
    public let setups: [SetupReference]
    
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        name = try decoder.decode("name")
        tempo = try decoder.decode("tempo")
        setups = try decoder.decode("setups")
    }
    
    public func toJSON() throws -> Any {
        return ["name": name,
                "tempo": tempo,
                "setups": try setups.toJSON()]
    }
    
    init(name: String, tempo: Double, setups: [SetupReference]) {
        self.name = name
        self.tempo = tempo
        self.setups = setups
    }
    
    static func new(name: String) -> Song {
        return Song(name: name, tempo: 100, setups: [])
    }
}
