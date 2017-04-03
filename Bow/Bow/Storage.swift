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

struct BoardsStorage {
    private let effectsFactory: EffectsFacory
    private let storageDirectory = NSHomeDirectory() + "/Documents/GuitarDsp/Boards"
    
    init(effectsFactory: EffectsFacory) {
        self.effectsFactory = effectsFactory
        setupFileSystem()
    }
    
    private func setupFileSystem() {
        if !FileManager.default.fileExists(atPath: storageDirectory) {
            try! FileManager.default.createDirectory(atPath: storageDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func save(board: Board, name: String) {
        var effectsJsonArray: JsonArray = []
        for effect in board.effects {
            effectsJsonArray.append(["type": effect.type(), "configuration": effect.configuration()])
        }
        let boardJsonObject = ["effects": effectsJsonArray] as [String : Any]
        NSKeyedArchiver.archiveRootObject(boardJsonObject, toFile: boardFilePath(name: name))
    }
    
    func load(name: String) -> Board? {
        guard let boardJsonObject = NSKeyedUnarchiver.unarchiveObject(withFile: boardFilePath(name: name)) as? JsonObject else {return nil}
        return try? load(json: boardJsonObject)
    }
    
    func index() -> [String] {
        return try! FileManager.default.contentsOfDirectory(atPath: storageDirectory).map{$0.components(separatedBy: ".").first!}
    }
    
    private func boardFilePath(name: String) -> String {
        return storageDirectory + "/\(name).board"
    }
    
    private func load(json: JsonObject) throws -> Board {
        var effects: [Effect] = []
        let effectsJsonArray = json["effects"] as! JsonArray
        for effectJsonObject in effectsJsonArray {
            var effect: Effect!
            let type = effectJsonObject["type"] as! String
            switch type {
            case "amp": effect = effectsFactory.all().first()! as AmpEffect
            case "reverb": effect = effectsFactory.all().first()! as ReverbEffect
            case "harmonizer": effect = effectsFactory.all().first()! as HarmonizerEffect
            case "phase_vocoder": effect = effectsFactory.all().first()! as PhaseVocoderEffect
            case "delay": effect = effectsFactory.all().first()! as DelayEffect
            default:
                assert(false, type)
            }
            try effect.configure(json: effectJsonObject["configuration"] as! JsonObject)
            effects.append(effect)
        }
        
        let board = Board()
        board.effects = effects
        return board
        
    }
    
    private func boardJsonObject(board: Board) -> JsonObject {
        var effectsJsonArray: JsonArray = []
        for effect in board.effects {
            effectsJsonArray.append(["type": effect.type(), "configuration": effect.configuration()])
        }
        return ["type": "board", "effects": effectsJsonArray]
    }
}

extension Effect {
    func configuration() -> JsonObject {
        if let ampEffect = self as? AmpEffect {
            return ["gain": ampEffect.gain]
        }
        if let reverbEffect = self as? ReverbEffect {
            return [
                "roomsize": reverbEffect.rev.getroomsize(),
                "damp": reverbEffect.rev.getdamp(),
                "wet": reverbEffect.rev.getwet(),
                "dry": reverbEffect.rev.getdry(),
                "width": reverbEffect.rev.getwidth()
            ]
        }
        if let harmonizerEffect = self as? HarmonizerEffect {
            return [
                "shift": harmonizerEffect.shift,
                "volume": harmonizerEffect.volume
            ]
        }
        if let phaseVocoderEffect = self as? PhaseVocoderEffect {
            return [
                "shift": phaseVocoderEffect.shift
            ]
        }
        if let delayEffect = self as? DelayEffect {
            return [
                "echoes_count": delayEffect.echoesCount,
                "tact_part": delayEffect.timing.tactPart.rawValue,
                "fa": delayEffect.fadingFunctionA,
                "fb": delayEffect.fadingFunctionB,
            ]
        }
        assert(false, "\(self)")
    }
    
    func type() -> String {
        switch self {
        case is AmpEffect: return "amp"
        case is ReverbEffect: return "reverb"
        case is HarmonizerEffect: return "harmonizer"
        case is PhaseVocoderEffect: return "phase_vocoder"
        case is DelayEffect: return "delay"
        default: assert(false, "\(self)")
        }
    }
    
    func configure(json: JsonObject) throws {
        let decoder = JSONDecoder(object: json)
        
        if let ampEffect = self as? AmpEffect {
            ampEffect.gain = try decoder.decode("gain")
        } else if let reverb = self as? ReverbEffect {
            reverb.rev.setroomsize(try decoder.decode("roomsize"))
            reverb.rev.setdamp(try decoder.decode("damp"))
            reverb.rev.setdry(try decoder.decode("dry"))
            reverb.rev.setwet(try decoder.decode("wet"))
            reverb.rev.setwidth(try decoder.decode("width"))
        } else if let harmonizerEffect = self as? HarmonizerEffect {
            harmonizerEffect.shift = try decoder.decode("shift")
            harmonizerEffect.volume = try decoder.decode("volume")
        } else if let phaseVocoderEffect = self as? PhaseVocoderEffect {
            phaseVocoderEffect.shift = try decoder.decode("shift")
        } else if let delayEffect = self as? DelayEffect {
            let tactPart = TactPart(rawValue: json["tact_part"] as! UInt)
            delayEffect.updateTact(tactPart!)
            delayEffect.updateEchoesCount(json["echoes_count"] as! Int32)
            delayEffect.fadingFunctionA = try decoder.decode("fa")
            delayEffect.fadingFunctionB = try decoder.decode("fb")
        } else {
            assert(false, "\(self)")
        }
    }
}

extension Array {
    func first<T>() -> T? {
        for element in self {
            if let firstElement = element as? T {
                return firstElement
            }
        }
        return nil
    }
}
