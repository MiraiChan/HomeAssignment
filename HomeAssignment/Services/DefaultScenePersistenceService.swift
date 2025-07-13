//
//  DefaultScenePersistenceService.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//

import Foundation

struct DefaultScenePersistenceService: ScenePersistence {
  func saveSceneString(_ sceneString: String) throws -> URL {
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let sceneURL = docs.appendingPathComponent("\(UUID().uuidString).scene")
    try sceneString.write(to: sceneURL, atomically: true, encoding: .utf8)
    return sceneURL
  }
}
