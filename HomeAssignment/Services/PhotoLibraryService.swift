//
//  PhotoLibraryService.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//

import Photos

struct PhotoLibraryService: ImageSaverProtocol {
  func saveImageToGallery(_ imageData: Data) async throws -> String? {
    var localId: String?
    try await PHPhotoLibrary.shared().performChanges {
      let request = PHAssetCreationRequest.forAsset()
      request.addResource(with: .photo, data: imageData, options: nil)
      localId = request.placeholderForCreatedAsset?.localIdentifier
    }
    return localId
  }
}
