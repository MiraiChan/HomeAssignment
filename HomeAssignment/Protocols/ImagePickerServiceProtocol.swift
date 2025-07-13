//
//  ImagePickerServiceProtocol.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//

import Foundation
import _PhotosUI_SwiftUI

protocol ImagePickerServiceProtocol {
  func loadPickedImage(from pickedItem: PhotosPickerItem?) async throws -> URL?
}
