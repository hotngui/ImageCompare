//
// Created by Joey Jarosz on 11/15/25.
// Copyright (c) 2025 hot-n-GUI, LLC. All rights reserved.
//

import SwiftUI
import AppKit
internal import UniformTypeIdentifiers

struct ImageLoadingCommands: Commands {
    @FocusedValue(\.image1) private var image1: Binding<NSImage?>?
    @FocusedValue(\.image2) private var image2: Binding<NSImage?>?
    
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Open Image 1...") {
                if let image1 {
                    openImagePicker(for: image1, title: "Select Image 1")
                }
            }
            .keyboardShortcut("1", modifiers: [.command])
            .disabled(image1 == nil)
            
            Button("Open Image 2...") {
                if let image2 {
                    openImagePicker(for: image2, title: "Select Image 2")
                }
            }
            .keyboardShortcut("2", modifiers: [.command])
            .disabled(image2 == nil)
            
            Divider()
        }
    }
    
    private func openImagePicker(for imageBinding: Binding<NSImage?>, title: String) {
        let panel = NSOpenPanel()
        panel.title = title
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.image]
        panel.message = "Choose an image file to load"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            if let image = NSImage(contentsOf: url) {
                imageBinding.wrappedValue = image
            }
        }
    }
}
