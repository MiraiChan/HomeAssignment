//
//  ImagePickerServiceProtocol.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//

import Foundation
import _PhotosUI_SwiftUI
// Protocol defining image picking service.
// Responsible for loading image data from a picked photo item.
protocol ImagePickerServiceProtocol {
  func loadPickedImage(from pickedItem: PhotosPickerItem?) async throws -> URL?
}
