//
//  PhotoLibraryService.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//

import Photos
// Service for saving image data into user's photo library.
struct PhotoLibraryService: ImageSaverProtocol {
  func saveImageToGallery(_ imageData: Data) async throws -> String? {
    var localId: String?
    try await PHPhotoLibrary.shared().performChanges {
      // Request to create a new photo asset with the image data
      let request = PHAssetCreationRequest.forAsset()
      request.addResource(with: .photo, data: imageData, options: nil)
      // Store the new photo's local identifier
      localId = request.placeholderForCreatedAsset?.localIdentifier
    }
    // Return the local identifier for future reference
    return localId
  }
}
