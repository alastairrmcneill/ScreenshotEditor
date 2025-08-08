//
//  CoreImageRenderer.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// Core Image-based renderer for real-time image processing
class CoreImageRenderer {
    
    static let shared = CoreImageRenderer()
    
    // MARK: - Private Properties
    private let ciContext: CIContext
    private let colorSpace: CGColorSpace
    
    // MARK: - Initialization
    private init() {
        // Create optimized CI context
        let options: [CIContextOption: Any] = [
            .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
            .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        ]
        
        // Try to use Metal if available, fallback to CPU
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            ciContext = CIContext(mtlDevice: metalDevice, options: options)
        } else {
            ciContext = CIContext(options: options)
        }
        
        colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    }
    
    // MARK: - Public Methods
    
    /// Renders an image with the provided parameters using Core Image
    /// - Parameters:
    ///   - image: Source image to process
    ///   - parameters: Editing parameters to apply
    /// - Returns: Processed UIImage
    func renderImage(from image: UIImage, parameters: ImageEditingParameters) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return image }
        
        var processedImage = ciImage
        
        // Apply crop if needed
        if parameters.cropRect != CGRect(x: 0, y: 0, width: 1, height: 1) {
            processedImage = applyCrop(to: processedImage, cropRect: parameters.cropRect)
        }
        
        // Apply corner radius if needed
        if parameters.cornerRadius > 0 {
            processedImage = applyCornerRadius(to: processedImage, radius: parameters.cornerRadius)
        }
        
        // Convert back to UIImage
        guard let cgImage = ciContext.createCGImage(processedImage, from: processedImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// Renders the final export image with background, padding, shadow, and optional watermark
    /// - Parameters:
    ///   - image: Source image to process
    ///   - parameters: Editing parameters to apply
    ///   - includeWatermark: Whether to include watermark
    /// - Returns: Final processed UIImage ready for export
    func renderFinalImage(from image: UIImage, parameters: ImageEditingParameters, includeWatermark: Bool = false) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return image }
        
        var processedImage = ciImage
        
        // Apply crop if needed
        if parameters.cropRect != CGRect(x: 0, y: 0, width: 1, height: 1) {
            processedImage = applyCrop(to: processedImage, cropRect: parameters.cropRect)
        }
        
        // Apply corner radius if needed
        if parameters.cornerRadius > 0 {
            processedImage = applyCornerRadius(to: processedImage, radius: parameters.cornerRadius)
        }
        
        // Calculate canvas size based on aspect ratio and padding
        let canvasSize = calculateCanvasSize(for: processedImage, parameters: parameters)
        
        // Create background
        let backgroundImage = createBackground(size: canvasSize, parameters: parameters)
        
        // Composite image onto background with padding
        let compositedImage = compositeImageOnBackground(
            foreground: processedImage,
            background: backgroundImage,
            parameters: parameters
        )
        
        // Apply shadow if enabled
        var finalImage = compositedImage
        if parameters.shadowEnabled {
            finalImage = applyShadow(to: finalImage, parameters: parameters)
        }
        
        // Convert to UIImage
        guard let cgImage = ciContext.createCGImage(finalImage, from: finalImage.extent) else {
            return image
        }
        
        var result = UIImage(cgImage: cgImage)
        
        // Add watermark if needed
        if includeWatermark {
            result = addWatermark(to: result)
        }
        
        return result
    }
    
    // MARK: - Private Core Image Operations
    
    private func applyCrop(to image: CIImage, cropRect: CGRect) -> CIImage {
        let imageExtent = image.extent
        let cropX = cropRect.origin.x * imageExtent.width
        let cropY = cropRect.origin.y * imageExtent.height
        let cropWidth = cropRect.width * imageExtent.width
        let cropHeight = cropRect.height * imageExtent.height
        
        let cropRectPixels = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
        return image.cropped(to: cropRectPixels)
    }
    
    private func applyCornerRadius(to image: CIImage, radius: CGFloat) -> CIImage {
        // For now, return the original image as corner radius with Core Image is complex
        // This will be implemented in a future iteration or using a different approach
        return image
    }
    
    private func calculateCanvasSize(for image: CIImage, parameters: ImageEditingParameters) -> CGSize {
        let imageSize = image.extent.size
        let padding = parameters.padding * 2 // Padding on all sides
        
        var canvasWidth = imageSize.width + padding
        var canvasHeight = imageSize.height + padding
        
        // Apply aspect ratio constraints
        if let aspectRatio = parameters.aspectRatio.ratio {
            if aspectRatio == 1.0 {
                // Square - use the larger dimension
                let maxDimension = max(canvasWidth, canvasHeight)
                canvasWidth = maxDimension
                canvasHeight = maxDimension
            } else if aspectRatio < 1.0 {
                // Portrait - adjust width based on height
                canvasWidth = canvasHeight * aspectRatio
            } else {
                // Landscape - adjust height based on width
                canvasHeight = canvasWidth / aspectRatio
            }
        }
        
        return CGSize(width: canvasWidth, height: canvasHeight)
    }
    
    private func createBackground(size: CGSize, parameters: ImageEditingParameters) -> CIImage {
        switch parameters.backgroundType {
        case .solid:
            return createSolidBackground(size: size, color: parameters.selectedSolidColor.color)
        case .gradient:
            return createGradientBackground(size: size, gradient: parameters.selectedGradient)
        }
    }
    
    private func createSolidBackground(size: CGSize, color: CGColor) -> CIImage {
        guard let filter = CIFilter(name: "CIConstantColorGenerator") else {
            return CIImage.empty()
        }
        
        filter.setValue(CIColor(cgColor: color), forKey: kCIInputColorKey)
        
        guard let colorImage = filter.outputImage else {
            return CIImage.empty()
        }
        
        return colorImage.cropped(to: CGRect(origin: .zero, size: size))
    }
    
    private func createGradientBackground(size: CGSize, gradient: BackgroundGradient) -> CIImage {
        let colors = gradient.colors
        guard colors.count >= 2 else {
            return createSolidBackground(size: size, color: colors.first ?? CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        }
        
        guard let filter = CIFilter(name: "CILinearGradient") else {
            return createSolidBackground(size: size, color: colors[0])
        }
        
        filter.setValue(CIVector(x: 0, y: 0), forKey: "inputPoint0")
        filter.setValue(CIVector(x: size.width, y: size.height), forKey: "inputPoint1")
        filter.setValue(CIColor(cgColor: colors[0]), forKey: "inputColor0")
        filter.setValue(CIColor(cgColor: colors[1]), forKey: "inputColor1")
        
        guard let gradientImage = filter.outputImage else {
            return createSolidBackground(size: size, color: colors[0])
        }
        
        return gradientImage.cropped(to: CGRect(origin: .zero, size: size))
    }
    
    private func compositeImageOnBackground(foreground: CIImage, background: CIImage, parameters: ImageEditingParameters) -> CIImage {
        let backgroundSize = background.extent.size
        let foregroundSize = foreground.extent.size
        
        // Calculate position to center the foreground image
        let x = (backgroundSize.width - foregroundSize.width) / 2
        let y = (backgroundSize.height - foregroundSize.height) / 2
        
        let translatedForeground = foreground.transformed(by: CGAffineTransform(translationX: x, y: y))
        
        guard let filter = CIFilter(name: "CISourceOverCompositing") else {
            return background
        }
        
        filter.setValue(translatedForeground, forKey: kCIInputImageKey)
        filter.setValue(background, forKey: kCIInputBackgroundImageKey)
        
        return filter.outputImage ?? background
    }
    
    private func applyShadow(to image: CIImage, parameters: ImageEditingParameters) -> CIImage {
        // Create shadow using Gaussian blur
        guard let shadowFilter = CIFilter(name: "CIGaussianBlur") else { return image }
        shadowFilter.setValue(image, forKey: kCIInputImageKey)
        shadowFilter.setValue(parameters.shadowBlur, forKey: kCIInputRadiusKey)
        
        guard let blurredShadow = shadowFilter.outputImage else { return image }
        
        // Offset shadow
        let offsetShadow = blurredShadow.transformed(by: CGAffineTransform(translationX: parameters.shadowOffset, y: -parameters.shadowOffset))
        
        // Apply shadow opacity using color matrix
        guard let opacityFilter = CIFilter(name: "CIColorMatrix") else { return image }
        opacityFilter.setValue(offsetShadow, forKey: kCIInputImageKey)
        opacityFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: parameters.shadowOpacity), forKey: "inputAVector")
        
        guard let fadedShadow = opacityFilter.outputImage else { return image }
        
        // Composite original image over shadow
        guard let compositeFilter = CIFilter(name: "CISourceOverCompositing") else { return image }
        compositeFilter.setValue(image, forKey: kCIInputImageKey)
        compositeFilter.setValue(fadedShadow, forKey: kCIInputBackgroundImageKey)
        
        return compositeFilter.outputImage ?? image
    }
    
    // MARK: - Watermark (UIKit-based for now)
    
    private func addWatermark(to image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        return renderer.image { context in
            // Draw the original image
            image.draw(at: .zero)
            
            // Configure watermark text
            let watermarkText = AppStrings.UI.madeWithSnapPolish
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
}
