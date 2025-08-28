//
//  SnackbarView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 15/08/2025.
//

import SwiftUI

/// A snackbar notification view that appears at the bottom of the screen
struct SnackbarView: View {
    let message: String
    let isShowing: Bool
    let icon: String?
    let backgroundColor: Color
    let textColor: Color
    
    init(
        message: String,
        isShowing: Bool,
        icon: String? = nil,
        backgroundColor: Color = Color(.systemBackground),
        textColor: Color = Color(.label)
    ) {
        self.message = message
        self.isShowing = isShowing
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
    
    /// Creates a success snackbar
    static func success(message: String, isShowing: Bool) -> SnackbarView {
        SnackbarView(
            message: message,
            isShowing: isShowing,
            icon: AppStrings.SystemImages.checkmarkCircleFill,
            backgroundColor: Color(.systemGreen),
            textColor: .white
        )
    }
    
    /// Creates an error snackbar
    static func error(message: String, isShowing: Bool) -> SnackbarView {
        SnackbarView(
            message: message,
            isShowing: isShowing,
            icon: AppStrings.SystemImages.xmark,
            backgroundColor: Color(.systemRed),
            textColor: .white
        )
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(textColor)
            }
            
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .offset(y: isShowing ? 0 : 100)
        .opacity(isShowing ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
    }
}

/// Manager for showing snackbar notifications
@MainActor
class SnackbarManager: ObservableObject {
    static let shared = SnackbarManager()
    
    @Published var isShowing = false
    @Published var message = ""
    @Published var snackbarType: SnackbarType = .success
    
    private var hideTask: Task<Void, Never>?
    
    private init() {}
    
    enum SnackbarType {
        case success
        case error
    }
    
    /// Shows a success snackbar
    func showSuccess(_ message: String, duration: TimeInterval = 3.0) {
        show(message: message, type: .success, duration: duration)
    }
    
    /// Shows an error snackbar
    func showError(_ message: String, duration: TimeInterval = 4.0) {
        show(message: message, type: .error, duration: duration)
    }
    
    private func show(message: String, type: SnackbarType, duration: TimeInterval) {
        // Cancel any existing hide task
        hideTask?.cancel()
        
        // Update the message and type
        self.message = message
        self.snackbarType = type
        
        // Show the snackbar
        withAnimation {
            isShowing = true
        }
        
        // Hide after duration
        hideTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            
            if !Task.isCancelled {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
    
    /// Manually hides the snackbar
    func hide() {
        hideTask?.cancel()
        withAnimation {
            isShowing = false
        }
    }
}

/// A view modifier that adds snackbar functionality to any view
struct SnackbarModifier: ViewModifier {
    @ObservedObject private var snackbarManager = SnackbarManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                Spacer()
                
                if snackbarManager.isShowing {
                    switch snackbarManager.snackbarType {
                    case .success:
                        SnackbarView.success(
                            message: snackbarManager.message,
                            isShowing: snackbarManager.isShowing
                        )
                    case .error:
                        SnackbarView.error(
                            message: snackbarManager.message,
                            isShowing: snackbarManager.isShowing
                        )
                    }
                }
            }
            .padding(.bottom, 16)
        }
    }
}

extension View {
    /// Adds snackbar functionality to a view
    func withSnackbar() -> some View {
        modifier(SnackbarModifier())
    }
}

#Preview("Success Snackbar") {
    VStack {
        Spacer()
        
        SnackbarView.success(
            message: "Image saved to Photos successfully!",
            isShowing: true
        )
        .padding(.bottom, 50)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
}

#Preview("Error Snackbar") {
    VStack {
        Spacer()
        
        SnackbarView.error(
            message: "Failed to save image. Please check your permissions.",
            isShowing: true
        )
        .padding(.bottom, 50)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
}
