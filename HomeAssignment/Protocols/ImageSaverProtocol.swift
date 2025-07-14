//
//  ImageSaverProtocol.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//

import Foundation
// Protocol defining service for saving image data to device's photo gallery.
protocol ImageSaverProtocol {
  func saveImageToGallery(_ imageData: Data) async throws -> String?
}
