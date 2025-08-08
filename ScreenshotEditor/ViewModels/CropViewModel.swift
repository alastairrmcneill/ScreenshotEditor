//
//  CropViewModel.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import Foundation
import UIKit
import SwiftUI

/// ViewModel for managing crop functionality and handle interactions
class CropViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var cropRect: CGRect
    @Published var imageSize: CGSize = .zero
    @Published var isDragging: Bool = false
    
    // MARK: - Private Properties
    private let originalImage: UIImage
    private var initialCropRect: CGRect
    
    // MARK: - Handle Properties
    enum Handle: CaseIterable {
        case topLeft, topCenter, topRight
        case centerLeft, centerRight
        case bottomLeft, bottomCenter, bottomRight
    }
    
    // MARK: - Initialization
    init(originalImage: UIImage, initialCropRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)) {
        self.originalImage = originalImage
        self.cropRect = initialCropRect
        self.initialCropRect = initialCropRect
        self.imageSize = originalImage.size
    }
    
    // MARK: - Public Methods
    
    /// Updates crop rect when dragging handles
    func updateCropRect(_ rect: CGRect) {
        // Ensure crop rect stays within bounds [0, 1]
        let constrainedRect = CGRect(
            x: max(AppConstants.Crop.minimumCropCoordinate, min(rect.origin.x, AppConstants.Crop.maximumCropCoordinate)),
            y: max(AppConstants.Crop.minimumCropCoordinate, min(rect.origin.y, AppConstants.Crop.maximumCropCoordinate)),
            width: max(AppConstants.Crop.minimumCropSize, min(rect.width, AppConstants.Crop.maximumCropCoordinate - rect.origin.x)), // Minimum 10% size
            height: max(AppConstants.Crop.minimumCropSize, min(rect.height, AppConstants.Crop.maximumCropCoordinate - rect.origin.y))
        )
        cropRect = constrainedRect
    }
    
    /// Resets crop to original state
    func resetCrop() {
        cropRect = CGRect(x: AppConstants.Crop.minimumCropCoordinate, y: AppConstants.Crop.minimumCropCoordinate, width: AppConstants.Crop.maximumCropCoordinate, height: AppConstants.Crop.maximumCropCoordinate)
    }
    
    /// Gets the position of a specific handle in normalized coordinates
    func getHandlePosition(_ handle: Handle) -> CGPoint {
        switch handle {
        case .topLeft:
            return CGPoint(x: cropRect.minX, y: cropRect.minY)
        case .topCenter:
            return CGPoint(x: cropRect.midX, y: cropRect.minY)
        case .topRight:
            return CGPoint(x: cropRect.maxX, y: cropRect.minY)
        case .centerLeft:
            return CGPoint(x: cropRect.minX, y: cropRect.midY)
        case .centerRight:
            return CGPoint(x: cropRect.maxX, y: cropRect.midY)
        case .bottomLeft:
            return CGPoint(x: cropRect.minX, y: cropRect.maxY)
        case .bottomCenter:
            return CGPoint(x: cropRect.midX, y: cropRect.maxY)
        case .bottomRight:
            return CGPoint(x: cropRect.maxX, y: cropRect.maxY)
        }
    }
    
    /// Updates crop rect based on handle drag
    func updateCropForHandle(_ handle: Handle, draggedTo point: CGPoint) {
        // Constrain the point to be within image bounds [0, 1]
        let constrainedPoint = CGPoint(
            x: max(AppConstants.Crop.minimumCropCoordinate, min(AppConstants.Crop.maximumCropCoordinate, point.x)),
            y: max(AppConstants.Crop.minimumCropCoordinate, min(AppConstants.Crop.maximumCropCoordinate, point.y))
        )
        
        var newRect = cropRect
        
        switch handle {
        case .topLeft:
            let newWidth = newRect.maxX - constrainedPoint.x
            let newHeight = newRect.maxY - constrainedPoint.y
            // Ensure minimum size
            if newWidth >= AppConstants.Crop.minimumCropSize && newHeight >= AppConstants.Crop.minimumCropSize {
                newRect = CGRect(
                    x: constrainedPoint.x,
                    y: constrainedPoint.y,
                    width: newWidth,
                    height: newHeight
                )
            }
            
        case .topCenter:
            let newHeight = newRect.maxY - constrainedPoint.y
            // Ensure minimum size
            if newHeight >= AppConstants.Crop.minimumCropSize {
                newRect = CGRect(
                    x: newRect.minX,
                    y: constrainedPoint.y,
                    width: newRect.width,
                    height: newHeight
                )
            }
            
        case .topRight:
            let newWidth = constrainedPoint.x - newRect.minX
            let newHeight = newRect.maxY - constrainedPoint.y
            // Ensure minimum size
            if newWidth >= AppConstants.Crop.minimumCropSize && newHeight >= AppConstants.Crop.minimumCropSize {
                newRect = CGRect(
                    x: newRect.minX,
                    y: constrainedPoint.y,
                    width: newWidth,
                    height: newHeight
                )
            }
            
        case .centerLeft:
            let newWidth = newRect.maxX - constrainedPoint.x
            // Ensure minimum size
            if newWidth >= AppConstants.Crop.minimumCropSize {
                newRect = CGRect(
                    x: constrainedPoint.x,
                    y: newRect.minY,
                    width: newWidth,
                    height: newRect.height
                )
            }
            
        case .centerRight:
            let newWidth = constrainedPoint.x - newRect.minX
            // Ensure minimum size
            if newWidth >= AppConstants.Crop.minimumCropSize {
                newRect = CGRect(
                    x: newRect.minX,
                    y: newRect.minY,
                    width: newWidth,
                    height: newRect.height
                )
            }
            
        case .bottomLeft:
            let newWidth = newRect.maxX - constrainedPoint.x
            let newHeight = constrainedPoint.y - newRect.minY
            // Ensure minimum size
            if newWidth >= AppConstants.Crop.minimumCropSize && newHeight >= AppConstants.Crop.minimumCropSize {
                newRect = CGRect(
                    x: constrainedPoint.x,
                    y: newRect.minY,
                    width: newWidth,
                    height: newHeight
                )
            }
            
        case .bottomCenter:
            let newHeight = constrainedPoint.y - newRect.minY
            // Ensure minimum size
            if newHeight >= AppConstants.Crop.minimumCropSize {
                newRect = CGRect(
                    x: newRect.minX,
                    y: newRect.minY,
                    width: newRect.width,
                    height: newHeight
                )
            }
            
        case .bottomRight:
            let newWidth = constrainedPoint.x - newRect.minX
            let newHeight = constrainedPoint.y - newRect.minY
            // Ensure minimum size
            if newWidth >= AppConstants.Crop.minimumCropSize && newHeight >= AppConstants.Crop.minimumCropSize {
                newRect = CGRect(
                    x: newRect.minX,
                    y: newRect.minY,
                    width: newWidth,
                    height: newHeight
                )
            }
        }
        
        updateCropRect(newRect)
    }
    
    /// Converts normalized crop rect to actual pixel coordinates
    func getCropRectInPixels() -> CGRect {
        return CGRect(
            x: cropRect.origin.x * imageSize.width,
            y: cropRect.origin.y * imageSize.height,
            width: cropRect.width * imageSize.width,
            height: cropRect.height * imageSize.height
        )
    }
}
