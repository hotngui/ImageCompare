//
// Created by Joey Jarosz on 10/30/25.
// Copyright (c) 2025 hot-n-GUI, LLC. All rights reserved.
//

import AppKit
import SwiftUI

// MARK: - Color Storage

@propertyWrapper
struct AppStorageColor: DynamicProperty {
    @AppStorage private var storedValue: String
    
    var wrappedValue: Color {
        get {
            guard let data = Data(base64Encoded: storedValue),
                  let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
                return defaultValue
            }
            return Color(nsColor: nsColor)
        }
        nonmutating set {
            let nsColor = NSColor(newValue)
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false) {
                storedValue = data.base64EncodedString()
            }
        }
    }
    
    var projectedValue: Binding<Color> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
    
    private let defaultValue: Color
    
    init(wrappedValue: Color, _ key: String) {
        self.defaultValue = wrappedValue
        self._storedValue = AppStorage(wrappedValue: "", key)
    }
}

// MARK: - Focused Value Keys

struct BackgroundColorKey: FocusedValueKey {
    typealias Value = Binding<Color>
}

struct Image1Key: FocusedValueKey {
    typealias Value = Binding<NSImage?>
}

struct Image2Key: FocusedValueKey {
    typealias Value = Binding<NSImage?>
}

extension FocusedValues {
    var backgroundColor: BackgroundColorKey.Value? {
        get { self[BackgroundColorKey.self] }
        set { self[BackgroundColorKey.self] = newValue }
    }
    
    var image1: Image1Key.Value? {
        get { self[Image1Key.self] }
        set { self[Image1Key.self] = newValue }
    }
    
    var image2: Image2Key.Value? {
        get { self[Image2Key.self] }
        set { self[Image2Key.self] = newValue }
    }
}

struct ContentView: View {
    @State private var diffImage: NSImage?
    @State private var image1: NSImage?
    @State private var image2: NSImage?
    @State private var areIdentical: Bool = false
    @State private var totalPixels: Int?
    @State private var differentPixels: Int?
    @State private var showSizeAlert = false
    @State private var sharedImageSize: CGSize?
    @AppStorageColor("backgroundColor") private var backgroundColor: Color = .black
    
    private let maxWidth: CGFloat = 600
    private let maxHeight: CGFloat = 800

    var body: some View {
        VStack {
            HStack {
                VStack {
                    ImageDropView(image: $image1, otherImage: $image2, diffImage: $diffImage, sharedImageSize: $sharedImageSize)
                        .border(Color.primary, width: 0.5)
                    Text("   ")
                }
                        
                VStack {
                    ImageDropView(image: $image2, otherImage: $image1, diffImage: $diffImage, sharedImageSize: $sharedImageSize)
                        .border(Color.primary, width: 0.5)
                    Text("   ")
                }

                compareButton
                
                VStack(alignment: .center) {
                    if let diffImage {
                        Image(nsImage: diffImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: sharedImageSize?.width, height: sharedImageSize?.height)
                            .overlay {
                                if areIdentical {
                                    Text("Images are Identical")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                            }
                    } else {
                        Rectangle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: sharedImageSize?.width, height: sharedImageSize?.height)
                            .border(Color.primary, width: 0.5)
                    }

                    HStack {
                        Text("Different Pixels: \(differentPixels?.formatted(.number) ?? "---")")
                        Spacer()
                        Text("Total Pixels: \(totalPixels?.formatted(.number) ?? "---")")
                    }
                    .frame(width: sharedImageSize?.width)
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .navigationTitle("Visual Image Compare")
        .onChange(of: image1) {
            if image1 == nil && image2 == nil {
                sharedImageSize = nil
            } else {
                updateSharedImageSize(for: image1)
            }
        }
        .onChange(of: image2) {
            if image1 == nil && image2 == nil {
                sharedImageSize = nil
            } else {
                updateSharedImageSize(for: image2)
            }
        }
        .alert("Size Mismatch", isPresented: $showSizeAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The images must be the same size to compare them.")
        }
        .onChange(of: backgroundColor) {
            diffImage = nil
        }
        .focusedSceneValue(\.backgroundColor, $backgroundColor)
        .focusedSceneValue(\.image1, $image1)
        .focusedSceneValue(\.image2, $image2)
    }
    
    private func updateSharedImageSize(for image: NSImage?) {
        guard let image else { return }
        
        if sharedImageSize == nil {
            let size = image.size
            let aspectRatio = size.width / size.height
            
            // Calculate the size constrained by both maxWidth and maxHeight
            var newWidth = size.width
            var newHeight = size.height
            
            // Check if width exceeds maxWidth
            if newWidth > maxWidth {
                newWidth = maxWidth
                newHeight = newWidth / aspectRatio
            }
            
            // Check if height still exceeds maxHeight
            if newHeight > maxHeight {
                newHeight = maxHeight
                newWidth = newHeight * aspectRatio
            }
            
            sharedImageSize = CGSize(width: newWidth, height: newHeight)
        }
    }

    private func compareImages(_ image1: CIImage, _ image2: CIImage, backgroundColor: Color) -> (image: NSImage?, areIdentical: Bool, totalPixels: Int, differentPixels: Int) {
        let ciContext = CIContext()
        let filter = CIFilter(name: "CIDifferenceBlendMode")
        
        filter?.setDefaults()
        filter?.setValue(image1, forKey: kCIInputImageKey)
        filter?.setValue(image2, forKey: kCIInputBackgroundImageKey)
        
        let (isIdentical, totalPixels, differentPixels) = areImagesIdentical(image1, image2)
        var diffImage: NSImage? = nil
        
        guard let outputImage = filter?.outputImage else {
            return (nil, isIdentical, totalPixels, differentPixels)
        }
        
        let extent = outputImage.extent
        
        // Amplify the differences so subtle changes are visible
        let exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter?.setValue(outputImage, forKey: kCIInputImageKey)
        exposureFilter?.setValue(4.0, forKey: kCIInputEVKey)
        
        guard let amplifiedDiff = exposureFilter?.outputImage else {
            return (nil, isIdentical, totalPixels, differentPixels)
        }
        
        // Create background color
        let nsColor = NSColor(backgroundColor)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let ciColor = CIColor(red: red, green: green, blue: blue, alpha: alpha)
        let colorBackground = CIImage(color: ciColor).cropped(to: extent)
        
        // Convert the amplified difference to grayscale to use as a mask
        // This gives us luminance: bright where different, dark where identical
        let grayscaleFilter = CIFilter(name: "CIPhotoEffectMono")
        grayscaleFilter?.setValue(amplifiedDiff, forKey: kCIInputImageKey)
        
        guard let grayscaleMask = grayscaleFilter?.outputImage else {
            return (nil, isIdentical, totalPixels, differentPixels)
        }
        
        // Use CIBlendWithMask:
        // - Where mask is WHITE (different pixels) → show amplifiedDiff (inputImage)
        // - Where mask is BLACK (identical pixels) → show colorBackground (backgroundImage)
        let blendFilter = CIFilter(name: "CIBlendWithMask")
        blendFilter?.setValue(amplifiedDiff, forKey: kCIInputImageKey)
        blendFilter?.setValue(colorBackground, forKey: kCIInputBackgroundImageKey)
        blendFilter?.setValue(grayscaleMask, forKey: kCIInputMaskImageKey)
        
        if let finalImage = blendFilter?.outputImage,
           let cgImage = ciContext.createCGImage(finalImage, from: extent) {
            diffImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        }
        
        return (diffImage, isIdentical, totalPixels, differentPixels)
    }
    private func areImagesIdentical(_ image1: CIImage, _ image2: CIImage) -> (Bool, Int, Int) {
        let ciContext = CIContext()
        
        // Ensure images have the same dimensions
        guard image1.extent == image2.extent else { return (false, 0, 0) }
        
        let extent = image1.extent
        let width = Int(extent.width)
        let height = Int(extent.height)
        let totalPixels = width * height
        
        var bitmap1 = [UInt8](repeating: 0, count: totalPixels * 4)
        var bitmap2 = [UInt8](repeating: 0, count: totalPixels * 4)
        
        ciContext.render(image1, toBitmap: &bitmap1, rowBytes: width * 4,
                       bounds: extent, format: .RGBA8, colorSpace: nil)
        ciContext.render(image2, toBitmap: &bitmap2, rowBytes: width * 4,
                       bounds: extent, format: .RGBA8, colorSpace: nil)
        
        // Count different pixels
        var differentPixels = 0
        for pixelIndex in 0..<totalPixels {
            let baseIndex = pixelIndex * 4
            let r1 = bitmap1[baseIndex]
            let g1 = bitmap1[baseIndex + 1]
            let b1 = bitmap1[baseIndex + 2]
            let a1 = bitmap1[baseIndex + 3]
            
            let r2 = bitmap2[baseIndex]
            let g2 = bitmap2[baseIndex + 1]
            let b2 = bitmap2[baseIndex + 2]
            let a2 = bitmap2[baseIndex + 3]
            
            if r1 != r2 || g1 != g2 || b1 != b2 || a1 != a2 {
                differentPixels += 1
            }
        }
        
        let areIdentical = differentPixels == 0
        return (areIdentical, totalPixels, differentPixels)
    }
    
    @ViewBuilder
    private var compareButton: some View {
        Button {
            guard let img1 = image1, let img2 = image2,
                  let cgImage1 = img1.cgImage(forProposedRect: nil, context: nil, hints: nil),
                  let cgImage2 = img2.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                return
            }
            
            // Check if images are the same size
            if img1.size != img2.size {
                showSizeAlert = true
                return
            }
            
            let ciImage1 = CIImage(cgImage: cgImage1)
            let ciImage2 = CIImage(cgImage: cgImage2)

            withAnimation {
                let result = compareImages(ciImage1, ciImage2, backgroundColor: backgroundColor)
                diffImage = result.image
                areIdentical = result.areIdentical
                totalPixels = result.totalPixels
                differentPixels = result.differentPixels
            }
        } label: {
            VStack() {
                Text("Compare")
                Image(systemName: "arrow.forward.circle.fill")
                    .imageScale(.large)
            }
        }
        .buttonStyle(.glass)
        .disabled(image1 == nil || image2 == nil)
        .fixedSize()
    }
}

#Preview {
    ContentView()
}
