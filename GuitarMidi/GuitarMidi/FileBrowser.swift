//
//  FileBrowser.swift
//  GuitarMidi
//
//  Created by Maciej Chmielewski on 22.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation

struct File {
    let path: String
}

struct FileBrowser {
    let root: String
    let extensions: [String]
    
    func makeTree() -> TreeElement<File> {
        return treeElementAtPath(root)
    }
    
    private func treeElementAtPath(_ path: String) -> TreeElement<File> {
        let action = TreeElement<File>.Action(select: {_ in}, pick: {_ in})
        
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if !isDirectory.boolValue {
            return .leaf(File(path: path), action: action)
        }
        
        if let children = try? FileManager.default.contentsOfDirectory(atPath: path) {
            return TreeElement<File>.branch(TreeElement<File>.Branch(name: path.components(separatedBy: "/").last!), elements: children.map{self.treeElementAtPath(path + "/" + $0)})
        }
        
        return "" as! TreeElement<File>
    }
}
