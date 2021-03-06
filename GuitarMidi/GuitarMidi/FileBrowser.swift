//
//  FileBrowser.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 22.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

struct FileBrowser {
    let root: String
    let extensions: [String]
    let selectAction: (File) -> Void
    let pickAction: (File) -> Void
    let selectDirectory: (String) -> Void
    
    func makeTree() -> TreeElement {
        return treeElementAtPath(root)
    }
    
    private func makeAction(file: File) -> TreeElement.Action {
        return TreeElement.Action(select: {
            self.selectAction(file)
        }, pick: {
            self.pickAction(file)
        })
    }
    
    private func treeElementAtPath(_ path: String) -> TreeElement {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if !isDirectory.boolValue {
            let file = File(path: path)
            return .leaf(file, action: makeAction(file: file))
        }
        
        if let children = try? FileManager.default.contentsOfDirectory(atPath: path) {
            let branch = TreeElement.Branch(name: path.components(separatedBy: "/").last ?? path)
            return TreeElement.branch(branch, elements: children.map{self.treeElementAtPath(path + "/" + $0)}) {
                self.selectDirectory(path)
            }
        }
        
        return "" as! TreeElement
    }
}

struct File: LeafRepresentable {
    let path: String
    
    var name: String {
        return path.components(separatedBy: "/").last ?? path
    }
}

extension FileBrowser {
    static func samples(selectAction: @escaping (File) -> Void, pickAction: @escaping (File) -> Void, directoryAction: @escaping (String) -> Void) -> FileBrowser {
        return FileBrowser(root: "/Users/maciejchmielewski/Documents/GuitarDsp/samples", extensions: StorageConstants.audioFileExtensions, selectAction: selectAction, pickAction: pickAction, selectDirectory: directoryAction)
    }
}
