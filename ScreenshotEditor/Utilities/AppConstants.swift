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
    }
    
    // MARK: - Shadow Constants
    struct Shadow {
        static let defaultOpacity: CGFloat = 0.1
        static let defaultRadius: CGFloat = 10
        static let defaultOffsetX: CGFloat = 0
        static let defaultOffsetY: CGFloat = 5
    }
}
