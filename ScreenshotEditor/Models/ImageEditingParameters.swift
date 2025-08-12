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
    var selectedGradient: BackgroundGradient = .sunset
    
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
    case sunset = "Sunset"
    case ocean = "Ocean"
    case forest = "Forest"
    case midnight = "Midnight"
    case rose = "Rose"
    case golden = "Golden"
    case aurora = "Aurora"
    case cosmic = "Cosmic"
    case tropical = "Tropical"
    case autumn = "Autumn"
    
    var colors: [CGColor] {
        switch self {
        case .sunset:
            return [
                CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),
                CGColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0)
            ]
        case .ocean:
            return [
                CGColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0),
                CGColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0)
            ]
        case .forest:
            return [
                CGColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0),
                CGColor(red: 0.5, green: 1.0, blue: 0.0, alpha: 1.0)
            ]
        case .midnight:
            return [
                CGColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0),
                CGColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
            ]
        case .rose:
            return [
                CGColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0),
                CGColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
            ]
        case .golden:
            return [
                CGColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0),
                CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
            ]
        case .aurora:
            return [
                CGColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0),
                CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0)
            ]
        case .cosmic:
            return [
                CGColor(red: 0.2, green: 0.0, blue: 0.4, alpha: 1.0),
                CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            ]
        case .tropical:
            return [
                CGColor(red: 0.0, green: 0.8, blue: 0.6, alpha: 1.0),
                CGColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)
            ]
        case .autumn:
            return [
                CGColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0),
                CGColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
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
