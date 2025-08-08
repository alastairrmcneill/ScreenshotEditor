//
//  PhotoPickerView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        
        // Try to use screenshot filter first, fallback to all photos if unavailable
        if #available(iOS 15.0, *) {
            configuration.filter = .screenshots
        } else {
            configuration.filter = .images
        }
        
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else {
                AnalyticsManager.shared.track("Photo Import Cancelled")
                return
            }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error loading image: \(error)")
                            AnalyticsManager.shared.track("Photo Import Failed", properties: [
                                "error": error.localizedDescription
                            ])
                            return
                        }
                        
                        if let uiImage = image as? UIImage {
                            self.parent.selectedImage = uiImage
                            AnalyticsManager.shared.track("Photo Import Success", properties: [
                                "image_width": Double(uiImage.size.width),
                                "image_height": Double(uiImage.size.height),
                                "has_alpha": uiImage.cgImage?.alphaInfo != .none ? true : false
                            ])
                        }
                    }
                }
            }
        }
    }
}
