//
//   EditedImageSceneModel.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 11.07.25.
//
import Foundation

// Data model representing a saved edited image scene.
// Stores photo identifier in gallery and URL to saved editing scene file.
struct EditedImageSceneModel: Codable {
  let assetLocalIdentifier: String // Photo's unique ID in photo library
  let sceneURL: URL // Local file URL where editing scene is saved
}
