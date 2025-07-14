//
//  DefaultSceneRestorationService.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 14.07.25.
//

import Foundation
import IMGLYEngine
// Default implementation for restoring a saved scene into the engine.
struct DefaultSceneRestorationService: SceneRestorationServiceProtocol {
  func restoreScene(from url: URL, in engine: Engine) async throws {
    do {
      // Read the scene string from file
      let sceneString = try String(contentsOf: url)
      // Load the scene into the engine
      try await engine.scene.load(from: sceneString)
    } catch {
      // If loading fails, create a blank new scene as fallback
      assertionFailure("❌ Failed to load scene: \(error)")
      let scene = try await engine.scene.create()
      let page = try await engine.block.create(.page)
      try await engine.block.appendChild(to: scene, child: page)
    }
  }
}
