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
