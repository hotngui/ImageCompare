//
// Created by Joey Jarosz on 10/30/25.
// Copyright (c) 2025 hot-n-GUI, LLC. All rights reserved.
//

import SwiftUI

@main
struct ImageCompareApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        //joey .restorationBehavior(.disabled)
        .defaultSize(width: 800, height: 450)
        .commands {
            ImageLoadingCommands()
            BackgroundColorCommands()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

