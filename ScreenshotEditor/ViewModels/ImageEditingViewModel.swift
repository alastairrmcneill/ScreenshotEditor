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
        // ViewModel is ready for use immediately
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
        updateParameter { $0.cornerRadius = radius }
    }
    
    /// Updates padding and triggers re-render
    func updatePadding(_ padding: CGFloat) {
        updateParameter { $0.padding = padding }
    }
    
    /// Updates shadow enabled state and triggers re-render
    func updateShadowEnabled(_ enabled: Bool) {
        updateParameter { $0.shadowEnabled = enabled }
    }
    
    /// Updates shadow offset and triggers re-render
    func updateShadowOffset(_ offset: CGFloat) {
        updateParameter { $0.shadowOffset = offset }
    }
    
    /// Updates shadow blur and triggers re-render
    func updateShadowBlur(_ blur: CGFloat) {
        updateParameter { $0.shadowBlur = blur }
    }
    
    /// Updates shadow opacity and triggers re-render
    func updateShadowOpacity(_ opacity: CGFloat) {
        updateParameter { $0.shadowOpacity = opacity }
    }
    
    /// Updates background type and triggers re-render
    func updateBackgroundType(_ type: BackgroundType) {
        updateParameter { $0.backgroundType = type }
    }
    
    /// Updates selected solid color and triggers re-render
    func updateSolidColor(_ color: BackgroundColor) {
        updateParameter { $0.selectedSolidColor = color }
    }
    
    /// Updates selected gradient and triggers re-render
    func updateGradient(_ gradient: BackgroundGradient) {
        updateParameter { $0.selectedGradient = gradient }
    }
    
    /// Updates aspect ratio and triggers re-render
    func updateAspectRatio(_ ratio: AspectRatio) {
        updateParameter { $0.aspectRatio = ratio }
    }
    
    /// Updates crop rect and triggers re-render
    func updateCropRect(_ rect: CGRect) {
        updateParameter { $0.cropRect = rect }
    }
    
    /// Resets all parameters to default values
    func resetParameters() {
        parameters = ImageEditingParameters.defaultParameters
        renderImage()
    }
    
    /// Generates the final export image with watermark if needed
    func generateFinalImage() -> UIImage? {
        guard let originalImage = originalImage else { return nil }
        
        let hasPremiumAccess = SubscriptionManager.shared.hasPremiumAccess
        return imageRenderer.renderFinalImage(
            from: originalImage,
            parameters: parameters,
            includeWatermark: !hasPremiumAccess
        )
    }
    
    // MARK: - Private Methods
    
    /// Generic helper method to update parameters and trigger re-render
    private func updateParameter(_ update: (inout ImageEditingParameters) -> Void) {
        update(&parameters)
        renderImage()
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
