//
//  AppDelegate.swift
//  NoMAD
//
//  Created by Joel Rennich on 7/8/16.
//  Copyright © 2016 Trusource Labs. All rights reserved.
//

import Cocoa
import SystemConfiguration
import Foundation

let notificationKey = Notification(name: Notification.Name(rawValue: "updateNow"), object: nil)
let notificationCenter = NotificationCenter.default
let notificationQueue = NotificationQueue.default

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {

        myLogger.logit(.base, message:"---NoMAD Initialized---")

        let defaultPreferences = NSDictionary(contentsOf: Bundle.main.url(forResource: "DefaultPreferences", withExtension: "plist")!)
        UserDefaults.standard.register(defaults: defaultPreferences as! [String : Any])

        //NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self

        func sendUpdateRequest() {

            NSLog("State change, checking things.")
            notificationQueue.enqueue(notificationKey, postingStyle: .now, coalesceMask: .onName, forModes: nil)
        }

        let changed: SCDynamicStoreCallBack = {SCDynamicStore,_,_ in

            NSLog("State change, checking things.")
            notificationQueue.enqueue(notificationKey, postingStyle: .now, coalesceMask: .onName, forModes: nil)

            if  ( defaults.string(forKey: Preferences.stateChangeAction) != nil ) {
                NSLog("Firing State Change Action")
                cliTask(defaults.string(forKey: Preferences.stateChangeAction)! + " &")
            }
        }

        var dynamicContext = SCDynamicStoreContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let dcAddress = withUnsafeMutablePointer(to: &dynamicContext, {UnsafeMutablePointer<SCDynamicStoreContext>($0)})

        // set a 15 minute timer to update everything

        Timer.scheduledTimer(timeInterval: 900, target: self, selector: #selector(sendUpdateMessage), userInfo: nil, repeats: true)


        if let dynamicStore = SCDynamicStoreCreate(kCFAllocatorDefault, "io.fti.networkconfigurationchanged" as CFString, changed, dcAddress){

            let keys: [CFString] = ["State:/Network/Global/IPv4" as CFString]
            let keysArray = keys as CFArray

            SCDynamicStoreSetNotificationKeys(dynamicStore, nil, keysArray)

            let loop = SCDynamicStoreCreateRunLoopSource(kCFAllocatorDefault, dynamicStore, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, CFRunLoopMode.defaultMode)


            CFRunLoopRun()
        }

        awakeFromNib()

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func sendUpdateMessage() -> Void {
        NSLog("It's been a while, checking things.")
        notificationQueue.enqueue(notificationKey, postingStyle: .now, coalesceMask: .onName, forModes: nil)
    }

}
