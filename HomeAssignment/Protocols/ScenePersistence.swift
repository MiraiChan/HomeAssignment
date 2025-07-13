//
//  ScenePersistence.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 13.07.25.
//
import Foundation

protocol ScenePersistence {
  func saveSceneString(_ sceneString: String) throws -> URL
}
