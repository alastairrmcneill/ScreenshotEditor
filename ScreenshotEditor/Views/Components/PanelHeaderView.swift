//
//  PanelHeaderView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

/// Reusable header for panels with title and done button
struct PanelHeaderView: View {
    let title: String
    let onDone: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(AppStrings.UI.done) {
                onDone()
            }
            .foregroundColor(.customAccent)
        }
    }
}

#Preview {
    PanelHeaderView(title: "Style") {
        // Preview action
    }
}
