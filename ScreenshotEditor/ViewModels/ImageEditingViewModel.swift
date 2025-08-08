//
//  ImageEditingViewModel.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import Foundation
import UIKit
import Combine

/// ViewModel for managing image editing state and rendering
class ImageEditingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var originalImage: UIImage?
    @Published var parameters = ImageEditingParameters.defaultParameters
    @Published var renderedImage: UIImage?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let imageRenderer = CoreImageRenderer.shared
    
    // MARK: - Initialization
    init() {
        setupParameterObservation()
    }
    
    // MARK: - Public Methods
    
    /// Sets the original image and triggers initial render
    func setOriginalImage(_ image: UIImage?) {
        originalImage = image
        if image != nil {
            renderImage()
        } else {
            renderedImage = nil
        }
    }
    
    /// Updates corner radius and triggers re-render
    func updateCornerRadius(_ radius: CGFloat) {
        objectWillChange.send()
        parameters.cornerRadius = radius
        renderImage()
    }
    
    /// Updates padding and triggers re-render
    func updatePadding(_ padding: CGFloat) {
        objectWillChange.send()
        parameters.padding = padding
        renderImage()
    }
    
    /// Updates shadow enabled state and triggers re-render
    func updateShadowEnabled(_ enabled: Bool) {
        objectWillChange.send()
        parameters.shadowEnabled = enabled
        renderImage()
    }
    
    /// Updates shadow offset and triggers re-render
    func updateShadowOffset(_ offset: CGFloat) {
        objectWillChange.send()
        parameters.shadowOffset = offset
        renderImage()
    }
    
    /// Updates shadow blur and triggers re-render
    func updateShadowBlur(_ blur: CGFloat) {
        objectWillChange.send()
        parameters.shadowBlur = blur
        renderImage()
    }
    
    /// Updates shadow opacity and triggers re-render
    func updateShadowOpacity(_ opacity: CGFloat) {
        objectWillChange.send()
        parameters.shadowOpacity = opacity
        renderImage()
    }
    
    /// Updates background type and triggers re-render
    func updateBackgroundType(_ type: BackgroundType) {
        objectWillChange.send()
        parameters.backgroundType = type
        renderImage()
    }
    
    /// Updates selected solid color and triggers re-render
    func updateSolidColor(_ color: BackgroundColor) {
        objectWillChange.send()
        parameters.selectedSolidColor = color
        renderImage()
    }
    
    /// Updates selected gradient and triggers re-render
    func updateGradient(_ gradient: BackgroundGradient) {
        objectWillChange.send()
        parameters.selectedGradient = gradient
        renderImage()
    }
    
    /// Updates aspect ratio and triggers re-render
    func updateAspectRatio(_ ratio: AspectRatio) {
        objectWillChange.send()
        parameters.aspectRatio = ratio
        renderImage()
    }
    
    /// Updates crop rect and triggers re-render
    func updateCropRect(_ rect: CGRect) {
        objectWillChange.send()
        parameters.cropRect = rect
        renderImage()
    }
    
    /// Resets all parameters to default values
    func resetParameters() {
        objectWillChange.send()
        parameters = ImageEditingParameters.defaultParameters
        renderImage()
    }
    
    /// Generates the final export image with watermark if needed
    func generateFinalImage() -> UIImage? {
        guard let originalImage = originalImage else { return nil }
        
        let isSubscribed = UserDefaultsManager.shared.isSubscribed
        return imageRenderer.renderFinalImage(
            from: originalImage,
            parameters: parameters,
            includeWatermark: !isSubscribed
        )
    }
    
    // MARK: - Private Methods
    
    /// Sets up observation of parameter changes for automatic re-rendering
    private func setupParameterObservation() {
        // Manual parameter updates handle rendering, no automatic observation needed
        // This method is kept for future use if we need automatic parameter observation
    }
    
    /// Renders the image with current parameters
    private func renderImage() {
        guard let originalImage = originalImage else {
            renderedImage = nil
            return
        }
        
        // Render on background queue to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let rendered = self.imageRenderer.renderImage(
                from: originalImage,
                parameters: self.parameters
            )
            
            DispatchQueue.main.async {
                self.renderedImage = rendered
            }
        }
    }
}
