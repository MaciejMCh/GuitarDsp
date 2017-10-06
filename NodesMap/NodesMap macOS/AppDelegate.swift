//
//  AppDelegate.swift
//  NodesMap macOS
//
//  Created by Maciej Chmielewski on 29.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let map = Map.mocked()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mapController = NSStoryboard(name: "Map", bundle: Bundle(for: Map.self)).instantiateInitialController() as! MapViewController
        mapController.map = map
        NSApplication.shared().windows.first!.contentViewController = mapController
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
