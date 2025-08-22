//
//  EditorControlButton.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 22/08/2025.
//

import SwiftUI

struct EditorControlButton: View {
    let systemImage: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.customAccent)
                    .padding(.vertical, 8)
                Text(text)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.customAccent)
                    .lineLimit(1)
            }
            .frame(width: 70, height: 70)
            .background(Color.buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        EditorControlButton(systemImage: "crop", text: "Crop") {
            // Preview action
        }
        
        EditorControlButton(systemImage: "square.on.square", text: "Style") {
            // Preview action
        }
        
        EditorControlButton(systemImage: "paintpalette", text: "Colours") {
            // Preview action
        }
    }
    .padding()
    .background(Color(.systemGray6))
}
