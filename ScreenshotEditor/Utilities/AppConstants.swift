//
//  AppConstants.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import Foundation
import CoreGraphics

/// Centralized constants for the app to avoid magic numbers and improve maintainability
struct AppConstants {
    
    // MARK: - Crop Constants
    struct Crop {
        /// Minimum crop size as a percentage (0.1 = 10%)
        static let minimumCropSize: CGFloat = 0.1
        /// Maximum crop coordinate (normalized to 1.0)
        static let maximumCropCoordinate: CGFloat = 1.0
        /// Minimum crop coordinate
        static let minimumCropCoordinate: CGFloat = 0.0
    }
    
    // MARK: - UI Layout Constants
    struct Layout {
        static let standardPadding: CGFloat = 16
        static let largePadding: CGFloat = 20
        static let extraLargePadding: CGFloat = 24
        static let hugePadding: CGFloat = 32
        static let buttonHorizontalPadding: CGFloat = 48
        static let cornerRadius: CGFloat = 8
        static let largeCornerRadius: CGFloat = 12
        
        // ContentView specific
        static let emptyStateIconSize: CGFloat = 64
        static let emptyStateTitleSpacing: CGFloat = 8
        static let emptyStateProgressScale: CGFloat = 0.8
        static let fallbackImageOpacity: CGFloat = 0.5
        static let controlsHorizontalPadding: CGFloat = 40
        static let navigationAreaSpacing: CGFloat = 2
        static let zeroSpacing: CGFloat = 0
    }
    
    // MARK: - Shadow Constants
    struct Shadow {
        static let defaultOpacity: CGFloat = 0.1
        static let defaultRadius: CGFloat = 10
        static let defaultOffsetX: CGFloat = 0
        static let defaultOffsetY: CGFloat = 5
    }
    
    // MARK: - Style Panel Constants
    struct StylePanel {
        static let maxCornerRadius: CGFloat = 200
        static let maxPadding: CGFloat = 200
        static let maxShadowBlur: CGFloat = 50
        static let backgroundOpacity: CGFloat = 0.3
        static let handleIndicatorWidth: CGFloat = 36
        static let handleIndicatorHeight: CGFloat = 6
        static let handleIndicatorCornerRadius: CGFloat = 3
        static let handleIndicatorOpacity: CGFloat = 0.6
        static let animationDuration: CGFloat = 0.3
    }
    
    // MARK: - RevenueCat Constants
    struct RevenueCat {
        static let apiKey: String = {
            guard let path = Bundle.main.path(forResource: "Config", ofType: "xcconfig"),
                  let contents = try? String(contentsOfFile: path),
                  let apiKey = contents.components(separatedBy: .newlines)
                    .first(where: { $0.hasPrefix("REVENUECAT_API_KEY") })?
                    .components(separatedBy: " = ").last?.trimmingCharacters(in: .whitespaces) else {
                return "appl_your_revenuecat_api_key_here" // Fallback
            }
            return apiKey
        }()
        static let weeklyProductId = "vanta_299_1w_3d0"
        static let yearlyProductId = "vanta_1499_1y"
        static let defaultOfferingId = "default"
    }
}
