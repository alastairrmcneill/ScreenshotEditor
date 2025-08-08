//
//  CropView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import SwiftUI

struct CropView: View {
    @StateObject private var cropViewModel: CropViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let originalImage: UIImage
    private let onCropComplete: (CGRect) -> Void
    
    // MARK: - Initialization
    init(
        originalImage: UIImage,
        initialCropRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1),
        onCropComplete: @escaping (CGRect) -> Void
    ) {
        self.originalImage = originalImage
        self.onCropComplete = onCropComplete
        self._cropViewModel = StateObject(wrappedValue: CropViewModel(
            originalImage: originalImage,
            initialCropRect: initialCropRect
        ))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    // Image with crop overlay
                    VStack {
                        Spacer()
                        
                        CropImageView(
                            image: originalImage,
                            cropViewModel: cropViewModel,
                            availableSize: CGSize(
                                width: geometry.size.width - 32,
                                height: geometry.size.height - 200 // Account for navigation and controls
                            )
                        )
                        
                        Spacer()
                        
                        // Bottom controls
                        HStack(spacing: 32) {
                            Button(AppStrings.UI.reset) {
                                cropViewModel.resetCrop()
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, AppConstants.Layout.standardPadding)
                            .padding(.vertical, AppConstants.Layout.cornerRadius)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(AppConstants.Layout.cornerRadius)
                            
                            Spacer()
                            
                            Button(AppStrings.UI.done) {
                                onCropComplete(cropViewModel.cropRect)
                                dismiss()
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, AppConstants.Layout.standardPadding)
                            .padding(.vertical, AppConstants.Layout.cornerRadius)
                            .background(Color.white)
                            .cornerRadius(AppConstants.Layout.cornerRadius)
                        }
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle(AppStrings.UI.crop)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.UI.cancel) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - CropImageView
struct CropImageView: View {
    let image: UIImage
    @ObservedObject var cropViewModel: CropViewModel
    let availableSize: CGSize
    
    @State private var imageFrame: CGRect = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let imageSize = calculateImageDisplaySize()
            let imageFrame = CGRect(
                x: (geometry.size.width - imageSize.width) / 2,
                y: (geometry.size.height - imageSize.height) / 2,
                width: imageSize.width,
                height: imageSize.height
            )
            
            ZStack {
                // Background image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
                
                // Crop overlay
                CropOverlayView(
                    cropViewModel: cropViewModel,
                    imageFrame: imageFrame
                )
            }
            .onAppear {
                self.imageFrame = imageFrame
            }
        }
        .frame(width: availableSize.width, height: availableSize.height)
    }
    
    private func calculateImageDisplaySize() -> CGSize {
        let imageAspectRatio = image.size.width / image.size.height
        let availableAspectRatio = availableSize.width / availableSize.height
        
        if imageAspectRatio > availableAspectRatio {
            // Image is wider than available space
            let width = availableSize.width
            let height = width / imageAspectRatio
            return CGSize(width: width, height: height)
        } else {
            // Image is taller than available space
            let height = availableSize.height
            let width = height * imageAspectRatio
            return CGSize(width: width, height: height)
        }
    }
}

// MARK: - CropOverlayView
struct CropOverlayView: View {
    @ObservedObject var cropViewModel: CropViewModel
    let imageFrame: CGRect
    
    var body: some View {
        ZStack {
            // Semi-transparent overlay outside crop area
            CropMaskView(cropRect: cropViewModel.cropRect, imageFrame: imageFrame)
            
            // Rule of thirds grid
            RuleOfThirdsGrid(cropRect: cropViewModel.cropRect, imageFrame: imageFrame)
            
            // Crop frame border
            CropFrameBorder(cropRect: cropViewModel.cropRect, imageFrame: imageFrame)
            
            // Drag handles
            ForEach(CropViewModel.Handle.allCases, id: \.self) { handle in
                CropHandle(
                    handle: handle,
                    cropViewModel: cropViewModel,
                    imageFrame: imageFrame
                )
            }
        }
    }
}

// MARK: - CropMaskView
struct CropMaskView: View {
    let cropRect: CGRect
    let imageFrame: CGRect
    
    var body: some View {
        let cropFrameInView = CGRect(
            x: imageFrame.minX + cropRect.minX * imageFrame.width,
            y: imageFrame.minY + cropRect.minY * imageFrame.height,
            width: cropRect.width * imageFrame.width,
            height: cropRect.height * imageFrame.height
        )
        
        // Create a mask that darkens everything except the crop area
        Rectangle()
            .fill(Color.black.opacity(0.5))
            .mask(
                Rectangle()
                    .fill(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(
                                width: cropFrameInView.width,
                                height: cropFrameInView.height
                            )
                            .position(
                                x: cropFrameInView.midX,
                                y: cropFrameInView.midY
                            )
                            .blendMode(.destinationOut)
                    )
            )
    }
}

// MARK: - RuleOfThirdsGrid
struct RuleOfThirdsGrid: View {
    let cropRect: CGRect
    let imageFrame: CGRect
    
    var body: some View {
        let cropFrameInView = CGRect(
            x: imageFrame.minX + cropRect.minX * imageFrame.width,
            y: imageFrame.minY + cropRect.minY * imageFrame.height,
            width: cropRect.width * imageFrame.width,
            height: cropRect.height * imageFrame.height
        )
        
        ZStack {
            // Vertical lines
            ForEach(1..<3) { i in
                let x = cropFrameInView.minX + (CGFloat(i) / 3.0) * cropFrameInView.width
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 1, height: cropFrameInView.height)
                    .position(x: x, y: cropFrameInView.midY)
            }
            
            // Horizontal lines
            ForEach(1..<3) { i in
                let y = cropFrameInView.minY + (CGFloat(i) / 3.0) * cropFrameInView.height
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: cropFrameInView.width, height: 1)
                    .position(x: cropFrameInView.midX, y: y)
            }
        }
    }
}

// MARK: - CropFrameBorder
struct CropFrameBorder: View {
    let cropRect: CGRect
    let imageFrame: CGRect
    
    var body: some View {
        let cropFrameInView = CGRect(
            x: imageFrame.minX + cropRect.minX * imageFrame.width,
            y: imageFrame.minY + cropRect.minY * imageFrame.height,
            width: cropRect.width * imageFrame.width,
            height: cropRect.height * imageFrame.height
        )
        
        Rectangle()
            .stroke(Color.white, lineWidth: 2)
            .frame(
                width: cropFrameInView.width,
                height: cropFrameInView.height
            )
            .position(
                x: cropFrameInView.midX,
                y: cropFrameInView.midY
            )
    }
}

// MARK: - CropHandle
struct CropHandle: View {
    let handle: CropViewModel.Handle
    @ObservedObject var cropViewModel: CropViewModel
    let imageFrame: CGRect
    
    private let handleSize: CGFloat = 20
    
    var body: some View {
        let handlePosition = cropViewModel.getHandlePosition(handle)
        let positionInView = CGPoint(
            x: imageFrame.minX + handlePosition.x * imageFrame.width,
            y: imageFrame.minY + handlePosition.y * imageFrame.height
        )
        
        Circle()
            .fill(Color.white)
            .frame(width: handleSize, height: handleSize)
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 1)
            )
            .position(positionInView)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        cropViewModel.isDragging = true
                        
                        // Convert drag position to normalized coordinates
                        let normalizedPoint = CGPoint(
                            x: (value.location.x - imageFrame.minX) / imageFrame.width,
                            y: (value.location.y - imageFrame.minY) / imageFrame.height
                        )
                        
                        cropViewModel.updateCropForHandle(handle, draggedTo: normalizedPoint)
                    }
                    .onEnded { _ in
                        cropViewModel.isDragging = false
                    }
            )
    }
}

// MARK: - Preview
#Preview {
    CropView(
        originalImage: UIImage(systemName: "photo") ?? UIImage(),
        onCropComplete: { _ in }
    )
}
