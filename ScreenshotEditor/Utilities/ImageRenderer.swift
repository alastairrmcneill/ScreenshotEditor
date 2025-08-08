//
//  ImageRenderer.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import UIKit
import SwiftUI

/// Utility class for rendering final images with watermarks and effects
class ImageRenderer {
    
    static let shared = ImageRenderer()
    
    private init() {}
    
    /// Renders the final image with watermark (if user is not subscribed)
    /// - Parameter sourceImage: The original image to render
    /// - Returns: The final rendered image with watermark if applicable
    func renderFinalImage(from sourceImage: UIImage) -> UIImage {
        let isSubscribed = UserDefaultsManager.shared.isSubscribed
        
        // If user is subscribed, return the original image
        if isSubscribed {
            return sourceImage
        }
        
        // For free users, add watermark
        return addWatermark(to: sourceImage)
    }
    
    /// Adds watermark to the provided image
    /// - Parameter image: The source image
    /// - Returns: Image with watermark overlay
    private func addWatermark(to image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        return renderer.image { context in
            // Draw the original image
            image.draw(at: .zero)
            
            // Configure watermark text
            let watermarkText = "Made with SnapPolish"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            
            let attributedString = NSAttributedString(string: watermarkText, attributes: attributes)
            let textSize = attributedString.size()
            
            // Calculate watermark position (bottom-right with padding)
            let padding: CGFloat = 12
            let backgroundPadding: CGFloat = 8
            let backgroundSize = CGSize(
                width: textSize.width + (backgroundPadding * 2),
                height: textSize.height + (backgroundPadding * 2)
            )
            
            let backgroundRect = CGRect(
                x: image.size.width - backgroundSize.width - padding,
                y: image.size.height - backgroundSize.height - padding,
                width: backgroundSize.width,
                height: backgroundSize.height
            )
            
            let textRect = CGRect(
                x: backgroundRect.origin.x + backgroundPadding,
                y: backgroundRect.origin.y + backgroundPadding,
                width: textSize.width,
                height: textSize.height
            )
            
            // Draw background for watermark
            let cgContext = context.cgContext
            cgContext.setFillColor(UIColor.black.withAlphaComponent(0.6).cgColor)
            cgContext.addPath(UIBezierPath(roundedRect: backgroundRect, cornerRadius: 4).cgPath)
            cgContext.fillPath()
            
            // Draw watermark text
            attributedString.draw(in: textRect)
        }
    }
    
    /// Creates a SwiftUI view representation of the image with watermark overlay
    /// - Parameters:
    ///   - image: The source image
    ///   - showWatermark: Whether to show the watermark overlay
    /// - Returns: A SwiftUI view with the image and optional watermark
    static func createImageView(image: UIImage, showWatermark: Bool = false) -> some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            if showWatermark {
                WatermarkOverlay()
                    .allowsHitTesting(false)
            }
        }
    }
}
