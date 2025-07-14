//
//  ScenePersistenceProtocol.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//
import Foundation
// Protocol for saving scene data (as a string) to a file on disk. Scene data like the structure, positioning of objects, effects, and so on.
protocol ScenePersistenceProtocol {
  func saveSceneString(_ sceneString: String) throws -> URL
}
