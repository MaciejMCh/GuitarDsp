//
//  AppDelegate.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 20.10.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import UIKit
import GuitarDsp
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var waveMap: WaveMap!
    let firebaseClient = FirebaseClient()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        WaveMapStorage.waveNodesFactory = WaveNodesFactory(samplingSettings: AudioInterface.shared().samplingSettings)
        
        FirebaseApp.configure()
        firebaseClient.sync()
        
//        waveMap = WaveMap(samplingSettings: AudioInterface.shared().samplingSettings, midiOutput: Sequencer())
        
        waveMap = .fromPath("flute", midiOutput: Sequencer())
//        waveMap = .fromPath("flute loop", midiOutput: Sequencer())
//        let sampler: Sampler = waveMap.waveNodes.first as! Sampler
//        sampler.player
        
        let mapCreatorViewController = UIStoryboard(name: "WaveMapCreator", bundle: nil).instantiateInitialViewController() as! MapCreatorViewController
        mapCreatorViewController.waveMapSource = .orphan
        mapCreatorViewController.waveMap = waveMap
        
        application.windows.first?.rootViewController = mapCreatorViewController
        application.windows.first?.makeKeyAndVisible()
        
        let samplingSettings = AudioInterface.shared().samplingSettings
        let processor = Processor(samplingSettings: samplingSettings, tempo: 120)
        let board = Board()
        board.effects = [waveMap]
        processor.activeBoard = board
        AudioInterface.shared().use(processor)
        mapCreatorViewController.mapChange = {
            board.effects = [$0]
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

