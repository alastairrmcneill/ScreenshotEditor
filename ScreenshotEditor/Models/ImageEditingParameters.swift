//
//  ImageEditingParameters.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import Foundation
import CoreGraphics

/// Model to store all image editing parameters for non-destructive editing
struct ImageEditingParameters {
    
    // MARK: - Crop Parameters
    var cropRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1) // Normalized coordinates (0-1)
    
    // MARK: - Style Parameters
    var cornerRadius: CGFloat = 0
    var padding: CGFloat = 24
    
    // MARK: - Shadow Parameters
    var shadowEnabled: Bool = false
    var shadowOffset: CGFloat = 0
    var shadowBlur: CGFloat = 0
    var shadowOpacity: CGFloat = 0.3
    
    // MARK: - Background Parameters
    var backgroundType: BackgroundType = .gradient
    var selectedSolidColor: BackgroundColor = .lightBlue
    var selectedGradient: BackgroundGradient = .blueToWhite
    
    // MARK: - Canvas Parameters
    var aspectRatio: AspectRatio = .free
    
    /// Default parameters for new editing sessions
    static let defaultParameters = ImageEditingParameters()
}

// MARK: - Background Types
enum BackgroundType: CaseIterable {
    case solid
    case gradient
}

// MARK: - Predefined Solid Colors
enum BackgroundColor: String, CaseIterable {
    case white = "White"
    case black = "Black"
    case lightBlue = "Light Blue"
    case lightPink = "Light Pink"
    case lightGreen = "Light Green"
    case lightPurple = "Light Purple"
    case peach = "Peach"
    case lavender = "Lavender"
    case mint = "Mint"
    case cream = "Cream"
    
    var color: CGColor {
        switch self {
        case .white:
            return CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .black:
            return CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        case .lightBlue:
            return CGColor(red: 0.68, green: 0.85, blue: 0.95, alpha: 1.0) // More visible pastel blue
        case .lightPink:
            return CGColor(red: 0.95, green: 0.68, blue: 0.85, alpha: 1.0) // More visible pastel pink
        case .lightGreen:
            return CGColor(red: 0.68, green: 0.95, blue: 0.75, alpha: 1.0) // More visible pastel green
        case .lightPurple:
            return CGColor(red: 0.85, green: 0.68, blue: 0.95, alpha: 1.0) // More visible pastel purple
        case .peach:
            return CGColor(red: 0.95, green: 0.80, blue: 0.68, alpha: 1.0) // More visible peach
        case .lavender:
            return CGColor(red: 0.80, green: 0.75, blue: 0.95, alpha: 1.0) // More visible lavender
        case .mint:
            return CGColor(red: 0.68, green: 0.95, blue: 0.88, alpha: 1.0) // More visible mint
        case .cream:
            return CGColor(red: 0.95, green: 0.90, blue: 0.75, alpha: 1.0) // More visible cream
        }
    }
}

// MARK: - Predefined Gradients
enum BackgroundGradient: String, CaseIterable {
    case blueToWhite = "Blue to White"
    case pinkToWhite = "Pink to White"
    case purpleToWhite = "Purple to White"
    case greenToWhite = "Green to White"
    case peachToWhite = "Peach to White"
    case lavenderToWhite = "Lavender to White"
    case mintToCream = "Mint to Cream"
    case peachToLavender = "Peach to Lavender"
    case blueToMint = "Blue to Mint"
    case pinkToPeach = "Pink to Peach"
    
    var colors: [CGColor] {
        switch self {
        case .blueToWhite:
            return [
                CGColor(red: 0.68, green: 0.85, blue: 0.95, alpha: 1.0), // More visible pastel blue
                CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)    // White
            ]
        case .pinkToWhite:
            return [
                CGColor(red: 0.95, green: 0.68, blue: 0.85, alpha: 1.0), // More visible pastel pink
                CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)    // White
            ]
        case .purpleToWhite:
            return [
                CGColor(red: 0.85, green: 0.68, blue: 0.95, alpha: 1.0), // More visible pastel purple
                CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)    // White
            ]
        case .greenToWhite:
            return [
                CGColor(red: 0.68, green: 0.95, blue: 0.75, alpha: 1.0), // More visible pastel green
                CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)    // White
            ]
        case .peachToWhite:
            return [
                CGColor(red: 0.95, green: 0.80, blue: 0.68, alpha: 1.0), // More visible peach
                CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)    // White
            ]
        case .lavenderToWhite:
            return [
                CGColor(red: 0.80, green: 0.75, blue: 0.95, alpha: 1.0), // More visible lavender
                CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)    // White
            ]
        case .mintToCream:
            return [
                CGColor(red: 0.68, green: 0.95, blue: 0.88, alpha: 1.0), // More visible mint
                CGColor(red: 0.95, green: 0.90, blue: 0.75, alpha: 1.0)  // More visible cream
            ]
        case .peachToLavender:
            return [
                CGColor(red: 0.95, green: 0.80, blue: 0.68, alpha: 1.0), // More visible peach
                CGColor(red: 0.80, green: 0.75, blue: 0.95, alpha: 1.0)  // More visible lavender
            ]
        case .blueToMint:
            return [
                CGColor(red: 0.68, green: 0.85, blue: 0.95, alpha: 1.0), // More visible pastel blue
                CGColor(red: 0.68, green: 0.95, blue: 0.88, alpha: 1.0)  // More visible mint
            ]
        case .pinkToPeach:
            return [
                CGColor(red: 0.95, green: 0.68, blue: 0.85, alpha: 1.0), // More visible pastel pink
                CGColor(red: 0.95, green: 0.80, blue: 0.68, alpha: 1.0)  // More visible peach
            ]
        }
    }
}

// MARK: - Aspect Ratios
enum AspectRatio: String, CaseIterable {
    case square = "1:1"
    case portrait = "9:16"
    case landscape = "16:9"
    case free = "Free"
    
    var ratio: CGFloat? {
        switch self {
        case .square:
            return 1.0
        case .portrait:
            return 9.0 / 16.0
        case .landscape:
            return 16.0 / 9.0
        case .free:
            return nil
        }
    }
}
