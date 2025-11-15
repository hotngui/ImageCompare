//
// Created by Joey Jarosz on 11/15/25.
// Copyright (c) 2025 hot-n-GUI, LLC. All rights reserved.
//

import SwiftUI
import AppKit

struct BackgroundColorCommands: Commands {
    @FocusedValue(\.backgroundColor) private var backgroundColor: Binding<Color>?
    
    var body: some Commands {
        CommandGroup(after: .pasteboard) {
            Button("Change Background Color...") {
                if let backgroundColor {
                    openColorPickerWindow(backgroundColor: backgroundColor)
                }
            }
            .keyboardShortcut("b", modifiers: [.command, .shift])
            .disabled(backgroundColor == nil)
        }
    }
    
    private func openColorPickerWindow(backgroundColor: Binding<Color>) {
        let colorPickerView = ColorPickerView(backgroundColor: backgroundColor)
        let hostingController = NSHostingController(rootView: colorPickerView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Background Color"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
    }
}

struct ColorPickerView: View {
    @Binding var backgroundColor: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Background Color")
                .font(.headline)
            
            ColorPicker("Background Color", selection: $backgroundColor, supportsOpacity: false)
            
            HStack {
                Spacer()
                
                Button("Done") {
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 300)
    }
}
