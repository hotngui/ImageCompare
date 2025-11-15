//
// Created by Joey Jarosz on 10/30/25.
// Copyright (c) 2025 hot-n-GUI, LLC. All rights reserved.
//

import AppKit
import CoreImage
import SwiftUI
internal import UniformTypeIdentifiers

struct ImageDropView: View {
    @Binding var image: NSImage?
    @Binding var otherImage: NSImage?
    @Binding var diffImage: NSImage?
    @Binding var sharedImageSize: CGSize?
    @State private var isImporting = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    let maxHeight: CGFloat = 800
    
    var body: some View {
        VStack (alignment: .leading) {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sharedImageSize?.width, height: sharedImageSize?.height)
                    .overlay(alignment: .topTrailing) {
                        Button("Clear Image") {
                            withAnimation {
                                self.image = nil
                                self.diffImage = nil
                            }
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.glass)
                        .tint(.red)
                        .padding()
                    }
                    .dropDestination(for: NSImage.self, isEnabled: true) { items, _ in
                        guard let nsImage = items.first else { return }
                        
                        withAnimation {
                            self.image = nsImage
                            self.diffImage = nil
                        }
                        
                        return
                    }
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .frame(width: sharedImageSize?.width, height: sharedImageSize?.height)
                    .dropDestination(for: NSImage.self, isEnabled: true) { items, _ in
                        guard let nsImage = items.first else { return }
                        
                        withAnimation {
                            self.image = nsImage
                            self.diffImage = nil
                        }
                        
                        return
                    }
                    .overlay {
                        VStack(spacing: 12) {
                            Button("Choose File") {
                                withAnimation {
                                    isImporting = true
                                }
                            }
                            .buttonStyle(.glass)
                            
                            Text("Or you can drop a file...")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .fileImporter(
                        isPresented: $isImporting,
                        allowedContentTypes: [.image],
                        allowsMultipleSelection: false
                    ) { result in
                        switch result {
                        case .success(let urls):
                            if let url = urls.first {
                                // Start accessing the security-scoped resource
                                let didStartAccessing = url.startAccessingSecurityScopedResource()
                                defer {
                                    if didStartAccessing {
                                        url.stopAccessingSecurityScopedResource()
                                    }
                                }
                                
                                withAnimation {
                                    if let nsImage = NSImage(contentsOf: url) {
                                        self.image = nsImage
                                        diffImage = nil
                                    } else {
                                        image = nil
                                        diffImage = nil
                                        
                                        errorMessage = "File was not an image."
                                        showError = true
                                    }
                                }
                            }
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                    .alert("Error Loading Image", isPresented: $showError) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        if let errorMessage {
                            Text(errorMessage)
                        }
                    }
            }
        }
    }
}

