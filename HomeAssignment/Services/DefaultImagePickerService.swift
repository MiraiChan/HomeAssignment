//
//  DefaultImagePickerService.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//

import Foundation
import Photos
import _PhotosUI_SwiftUI

struct DefaultImagePickerService: ImagePickerServiceProtocol {
  func loadPickedImage(from pickedItem: PhotosPickerItem?) async throws -> URL? {
    guard let data = try await pickedItem?.loadTransferable(type: Data.self) else { return nil }
    let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("picked_image.jpg")
    try data.write(to: tmpURL)
    return tmpURL
  }
}
