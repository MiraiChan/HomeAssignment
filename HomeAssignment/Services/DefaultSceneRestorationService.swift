//
//  DefaultSceneRestorationService.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 14.07.25.
//

import Foundation
import IMGLYEngine

struct DefaultSceneRestorationService: SceneRestorationServiceProtocol {
  func restoreScene(from url: URL, in engine: Engine) async throws {
    do {
      let sceneString = try String(contentsOf: url)
      try await engine.scene.load(from: sceneString)
    } catch {
      print("Ошибка загрузки сцены: \(error)")
      // fallback: создаём новую сцену
      let scene = try await engine.scene.create()
      let page = try await engine.block.create(.page)
      try await engine.block.appendChild(to: scene, child: page)
    }
  }
}
