//
//  StyleSliderViewModel.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import Foundation
import SwiftUI

/// ViewModel for managing slider state and temporary values during dragging
class StyleSliderViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var tempCornerRadius: CGFloat = 50
    @Published var tempPadding: CGFloat = 140
    @Published var tempShadowBlur: CGFloat = 13
    
    // MARK: - Private Properties
    private var isDraggingCornerRadius = false
    private var isDraggingPadding = false
    private var isDraggingShadowBlur = false
    
    // MARK: - Public Methods
    
    /// Updates temp value and manages dragging state for corner radius
    func updateCornerRadiusValue(_ value: CGFloat) {
        tempCornerRadius = value
        if !isDraggingCornerRadius {
            isDraggingCornerRadius = true
        }
    }
    
    /// Handles corner radius editing finished
    func finishCornerRadiusEditing(editingViewModel: ImageEditingViewModel) {
        if isDraggingCornerRadius {
            editingViewModel.updateCornerRadius(tempCornerRadius)
            isDraggingCornerRadius = false
        }
    }
    
    /// Updates temp value and manages dragging state for padding
    func updatePaddingValue(_ value: CGFloat) {
        tempPadding = value
        if !isDraggingPadding {
            isDraggingPadding = true
        }
    }
    
    /// Handles padding editing finished
    func finishPaddingEditing(editingViewModel: ImageEditingViewModel) {
        if isDraggingPadding {
            editingViewModel.updatePadding(tempPadding)
            isDraggingPadding = false
        }
    }
    
    /// Updates temp value and manages dragging state for shadow
    func updateShadowValue(_ value: CGFloat) {
        tempShadowBlur = value
        if !isDraggingShadowBlur {
            isDraggingShadowBlur = true
        }
    }
    
    /// Handles shadow editing finished
    func finishShadowEditing(editingViewModel: ImageEditingViewModel) {
        if isDraggingShadowBlur {
            editingViewModel.updateShadowOffset(0) // Fixed at 0
            editingViewModel.updateShadowOpacity(0.3) // Fixed at 30%
            editingViewModel.updateShadowBlur(tempShadowBlur)
            editingViewModel.updateShadowEnabled(tempShadowBlur > 0)
            isDraggingShadowBlur = false
        }
    }
    
    /// Gets the display value for corner radius
    func getCornerRadiusValue(from editingViewModel: ImageEditingViewModel) -> CGFloat {
        return isDraggingCornerRadius ? tempCornerRadius : editingViewModel.parameters.cornerRadius
    }
    
    /// Gets the display value for padding
    func getPaddingValue(from editingViewModel: ImageEditingViewModel) -> CGFloat {
        return isDraggingPadding ? tempPadding : editingViewModel.parameters.padding
    }
    
    /// Gets the display value for shadow
    func getShadowValue(from editingViewModel: ImageEditingViewModel) -> CGFloat {
        return isDraggingShadowBlur ? tempShadowBlur : editingViewModel.parameters.shadowBlur
    }
    
    /// Initializes temp values from current parameters
    func initializeValues(from editingViewModel: ImageEditingViewModel) {
        tempCornerRadius = editingViewModel.parameters.cornerRadius
        tempPadding = editingViewModel.parameters.padding
        tempShadowBlur = editingViewModel.parameters.shadowBlur
    }
}
