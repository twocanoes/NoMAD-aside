//
//  PreferencesWindow.swift
//  NoMAD
//
//  Created by Joel Rennich on 4/21/16.
//  Copyright © 2016 Trusource Labs. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func doTheNeedfull()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    var delegate: PreferencesWindowDelegate?

    @IBOutlet weak var ADDomainTextField: NSTextField!
    @IBOutlet weak var KerberosRealmField: NSTextField!
    //@IBOutlet weak var InternalSiteField: NSTextField!
    //@IBOutlet weak var InternalSiteIPField: NSTextField!
    @IBOutlet weak var x509CAField: NSTextField!
    @IBOutlet weak var TemplateField: NSTextField!
    @IBOutlet weak var ButtonNameField: NSTextField!
    @IBOutlet weak var HotKeyField: NSTextField!
    @IBOutlet weak var CommandField: NSTextField!
    @IBOutlet weak var SecondsToRenew: NSTextField!

    // Check boxes
    @IBOutlet weak var UseKeychain: NSButton!
    @IBOutlet weak var RenewTickets: NSButton!
    @IBOutlet weak var ShowHome: NSButton!

    override var windowNibName: String? {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()

        guard let controls = self.window?.contentView?.subviews else {
            myLogger.logit(.debug, message: "Preference window somehow drew without any controls.")
            return
        }

        //Disable managed preferences
        for object in controls {
            let identifier = object.identifier
            if defaults.objectIsForced(forKey: identifier!) {
                switch object.className {
                case "NSTextField":
                    let textField = object as! NSTextField
                    textField.isEnabled = false
                case "NSButton":
                    let button = object as! NSButton
                    button.isEnabled = false
                default:
                    return
                }
            }
        }
    }

    func windowShouldClose(_ sender: Any) -> Bool {

        // Make sure we have an AD Domain
        if ADDomainTextField.stringValue == "" {
            let alertController = NSAlert()
            alertController.messageText = "The AD Domain needs to be filled out."
            alertController.addButton(withTitle: "OK")
            alertController.addButton(withTitle: "Quit NoMAD")
            alertController.beginSheetModal(for: self.window!) { response in
                if response == 1001 {
                    NSApp.terminate(self)
                }
            }
            return false
        }
        return true
    }

    func windowWillClose(_ notification: Notification) {
        defaults.set(ADDomainTextField.stringValue.uppercased(), forKey: Preferences.kerberosRealm)
        notificationCenter.post(notificationKey)
    }
}
