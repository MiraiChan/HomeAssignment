//
//  ImageSaverProtocol.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//

import Foundation

protocol ImageSaverProtocol {
  func saveImageToGallery(_ imageData: Data) async throws -> String?
}
