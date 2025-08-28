//
//  PhotosLibraryManager.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 12/08/2025.
//

import Foundation
import Photos
import UIKit

/// Manager for saving images to the Photos library
class PhotosLibraryManager {
    static let shared = PhotosLibraryManager()
    
    private init() {}
    
    /// Saves an image to the Photos library
    /// - Parameter image: The UIImage to save
    /// - Returns: Success or failure
    func saveImageToPhotos(_ image: UIImage) async throws {
        // Request permission first
        let status = await requestPhotosPermission()
        
        guard status == .authorized || status == .limited else {
            throw PhotosError.accessDenied
        }
        
        // Save the image
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest.creationRequestForAsset(from: image)
        }
    }
    
    /// Requests permission to add photos to the library
    /// - Returns: The authorization status
    private func requestPhotosPermission() async -> PHAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }
}

/// Errors that can occur when saving to Photos
enum PhotosError: LocalizedError {
    case accessDenied
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Access to Photos library was denied. Please enable it in Settings."
        case .saveFailed:
            return "Failed to save image to Photos library."
        }
    }
}
