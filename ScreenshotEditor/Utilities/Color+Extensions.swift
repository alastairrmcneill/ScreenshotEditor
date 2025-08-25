//
//  Color+Extensions.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

extension Color {
    /// System-adaptive accent color: dark grey in light mode, off-white in dark mode
    static let customAccent = Color(
        light: Color(red: 0.2, green: 0.2, blue: 0.2), // Dark grey for light mode
        dark: Color(red: 0.9, green: 0.9, blue: 0.9)   // Off-white for dark mode
    )
    
    /// Button background color: white in light mode, lighter dark grey in dark mode
    static let editingButtonBackground = Color(
        light: Color.white,                             // White for light mode
        dark: Color(red: 0.2, green: 0.2, blue: 0.2)   // Lighter dark grey for dark mode
    )

        /// Button background color: white in light mode, lighter dark grey in dark mode
    static let buttonBackground = Color(
        light: Color(red: 0.2, green: 0.2, blue: 0.2),
        dark: Color(red: 0.2, green: 0.2, blue: 0.2)
    )

    /// Aspect ratio control background color: dark grey in light mode, off-white in dark mode
    static let aspectRatioButtonBackground = Color(
        light: Color(red: 0.2, green: 0.2, blue: 0.2),
        dark: Color(red: 0.2, green: 0.2, blue: 0.2)
    )

    /// Aspect ratio control foreground color: white in light mode, dark grey in dark mode
    static let aspectRatioButtonForeground = Color(
        light: Color.white,
        dark: Color(red: 0.2, green: 0.2, blue: 0.2)
    )

    static let aspectRatioButtonSelectedBackground = Color(
        light: Color(red: 0.2, green: 0.2, blue: 0.2),
        dark: Color(red: 0.3, green: 0.3, blue: 0.3)
    )

    static let aspectRatioButtonSelectedForeground = Color(
        light: Color(red: 0.2, green: 0.2, blue: 0.2),
        dark: Color.white
    )
}

extension Color {
    /// Creates a color that adapts to the current color scheme
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
