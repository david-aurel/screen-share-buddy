//
//  RegionShareApp.swift
//  Region Share
//
//  Created by David on 30.03.23.
//

import SwiftUI

// override style of the main window as soon as it has been created.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.titlebarAppearsTransparent = true
        }
    }
}

@main
struct RegionShareApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
