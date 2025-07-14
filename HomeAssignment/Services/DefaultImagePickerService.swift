//
//  DefaultImagePickerService.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//

import Foundation
import Photos
import _PhotosUI_SwiftUI
// Default implementation for image picking service.
// Converts picked photo item into a temporary file URL.
struct DefaultImagePickerService: ImagePickerServiceProtocol {
  func loadPickedImage(from pickedItem: PhotosPickerItem?) async throws -> URL? {
    // Load raw data from the picked photo item
    guard let data = try await pickedItem?.loadTransferable(type: Data.self) else { return nil }
    // Write data to a temporary file for further processing
    let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("picked_image.jpg")
    try data.write(to: tmpURL)
    return tmpURL
  }
}
