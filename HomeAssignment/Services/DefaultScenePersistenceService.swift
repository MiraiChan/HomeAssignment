//
//  DefaultScenePersistenceService.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//

import Foundation
// Default implementation for saving a scene string to a file.
struct DefaultScenePersistenceService: ScenePersistenceProtocol {
  func saveSceneString(_ sceneString: String) throws -> URL {
    // Get documents directory to save the file
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    // Create a unique filename for the scene file
    let sceneURL = docs.appendingPathComponent("\(UUID().uuidString).scene")
    // Write scene string data to file
    try sceneString.write(to: sceneURL, atomically: true, encoding: .utf8)
    return sceneURL
  }
}
