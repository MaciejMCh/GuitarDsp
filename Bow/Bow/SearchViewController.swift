//
//  SearchViewController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 03.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa
import GuitarDsp

class SearchViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchTextField: SearchTextField!
    
    var configuration: Configuration!
    
    private var currentSearchResults: [String] = [] {
        didSet {
            tableView.reloadData()
            tableView.selectRowIndexes([0], byExtendingSelection: false)
        }
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        let textView = obj.userInfo!["NSFieldEditor"] as! NSTextView
        currentSearchResults = configuration.search(textView.string!)
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        configuration.action(currentSearchResults[tableView.selectedRow])
        dismissViewController(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentSearchResults = configuration.search("")
        searchTextField.keyboardAction = { [weak self] in
            guard let wSelf = self else {return}
            if wSelf.tableView.numberOfRows == 0 {
                return
            }
            
            let indexChange: Int
            switch $0 {
            case .up: indexChange = -1 + wSelf.tableView.numberOfRows
            case .down: indexChange = 1
            }
            
            wSelf.tableView.selectRowIndexes([(wSelf.tableView.selectedRow + indexChange) % wSelf.tableView.numberOfRows], byExtendingSelection: false)
            
        }
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let searchRowView = tableView.make(withIdentifier: "SearchRowView", owner: nil) as! SearchRowView
        let searchResult = currentSearchResults[row]
        searchRowView.label.stringValue = searchResult
        return searchRowView
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return currentSearchResults.count
    }
}

class SearchRowView: NSTableRowView {
    @IBOutlet weak var label: NSTextField!
}

extension SearchViewController {
    struct Configuration {
        let search: (String) -> [String]
        let action: (String) -> Void
    }
}

extension SearchViewController {
    func searchForBoards(storage: BoardsStorage, action: @escaping (Board) -> ()) {
        let index = storage.index()
        configuration = Configuration(search: { (query: String) -> [String] in
            switch query {
            case "": return index
            default: return index.filter{$0.contains(query)}
            }
        }, action: { (selected: String) in
            if let board = storage.load(name: selected) {
                action(board)
            }
        })
    }
}

class SearchTextField: NSTextField {
    var keyboardAction: ((KeyboardAction) -> ())?
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        switch event.keyCode {
        case 126:
            keyboardAction?(.up)
            return true
        case 125:
            keyboardAction?(.down)
            return true
        default: return super.performKeyEquivalent(with: event)
        }
    }
}

extension SearchTextField {
    enum KeyboardAction {
        case up
        case down
    }
}
