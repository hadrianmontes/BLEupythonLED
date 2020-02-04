//
//  AppDelegate.swift
//  LED BLE Controller
//
//  Created by Hadrián Montes Campos on 23/01/2020.
//  Copyright © 2020 Hadrián Montes Campos. All rights reserved.
//

import Cocoa
import SwiftUI
import ble_backend

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var delegate = ble_backend.UPythonCommunicator()
    var statusBarItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        print("test")
        delegate.connect_and_wait()
        print("test")
        var data1 = delegate.uled.read(service: "0001", characteristic: "0001")
        guard let statusButton = statusBarItem.button else { return }
        statusButton.title = String(decoding: data1, as: UTF8.self)
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

