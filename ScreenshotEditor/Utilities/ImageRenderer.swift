//
//  ImageRenderer.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import UIKit
import SwiftUI

/// Legacy utility class for rendering final images - now delegates to CoreImageRenderer
/// Kept for backward compatibility during transition
class ImageRenderer {
    
    static let shared = ImageRenderer()
    
    private init() {}
    
    /// Renders the final image with watermark (if user is not subscribed)
    /// - Parameter sourceImage: The original image to render
    /// - Returns: The final rendered image with watermark if applicable
    func renderFinalImage(from sourceImage: UIImage) -> UIImage {
        let isSubscribed = UserDefaultsManager.shared.isSubscribed
        let parameters = ImageEditingParameters.defaultParameters
        
        // Use the new Core Image renderer
        return CoreImageRenderer.shared.renderFinalImage(
            from: sourceImage,
            parameters: parameters,
            includeWatermark: !isSubscribed
        ) ?? sourceImage
    }
    
    /// Renders the final image with custom parameters and optional watermark
    /// - Parameters:
    ///   - sourceImage: The original image to render
    ///   - parameters: The editing parameters to apply
    ///   - includeWatermark: Whether to include the watermark
    /// - Returns: The final rendered image with all effects applied
    func renderFinalImage(from sourceImage: UIImage, parameters: ImageEditingParameters, includeWatermark: Bool) -> UIImage? {
        return CoreImageRenderer.shared.renderFinalImage(
            from: sourceImage,
            parameters: parameters,
            includeWatermark: includeWatermark
        )
    }
    
    /// Creates a SwiftUI view representation of the image with live rendering
    /// - Parameters:
    ///   - image: The source image
    ///   - showWatermark: Whether to show the watermark overlay
    ///   - parameters: Optional editing parameters for live preview
    /// - Returns: A SwiftUI view with the processed image and optional watermark
    static func createImageView(image: UIImage, showWatermark: Bool = false, parameters: ImageEditingParameters? = nil) -> some View {
        let displayImage: UIImage
        
        if let params = parameters {
            // Use Core Image renderer for live preview
            displayImage = CoreImageRenderer.shared.renderImage(from: image, parameters: params) ?? image
        } else {
            displayImage = image
        }
        
        return ZStack {
            Image(uiImage: displayImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            if showWatermark {
                WatermarkOverlay()
                    .allowsHitTesting(false)
            }
        }
    }
}
