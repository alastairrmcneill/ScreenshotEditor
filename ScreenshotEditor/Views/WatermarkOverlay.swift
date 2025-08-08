//
//  WatermarkOverlay.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import SwiftUI

/// A view that displays a watermark overlay for free users
struct WatermarkOverlay: View {
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Text(AppStrings.UI.madeWithSnapPolish)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black.opacity(0.6))
                    )
                    .padding(.trailing, 12)
                    .padding(.bottom, 12)
            }
        }
    }
}

#Preview {
    ZStack {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 300, height: 400)
        
        WatermarkOverlay()
    }
}
