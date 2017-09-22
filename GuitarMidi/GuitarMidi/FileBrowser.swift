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
            return TreeElement.branch(TreeElement.Branch(name: path.components(separatedBy: "/").last ?? path), elements: children.map{self.treeElementAtPath(path + "/" + $0)})
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
    static func samples(selectAction: @escaping (File) -> Void, pickAction: @escaping (File) -> Void) -> FileBrowser {
        return FileBrowser(root: "/Users/maciejchmielewski/Documents/GuitarDsp/samples", extensions: ["wav"], selectAction: selectAction, pickAction: pickAction)
    }
}
