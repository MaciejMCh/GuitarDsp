//
//  TagPickerController.swift
//  Bow
//
//  Created by Maciej Chmielewski on 04.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import Cocoa

class TagPickerController: NSViewController {
    static func withCompletion(completion: @escaping (String) -> ()) -> TagPickerController {
        let me = make()
        me.completion = completion
        return me
    }
    
    var completion: ((String) -> ())!
    
    @IBAction func pickerFieldAction(textField: NSTextField) {
        dismissViewController(self)
        completion(textField.stringValue)
    }
}
