//
//  SceneRestorationServiceProtocol.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 14.07.25.
//

import Foundation
import IMGLYEngine
// Protocol to restore (load) a saved scene from file into the editing engine.
protocol SceneRestorationServiceProtocol {
  func restoreScene(from url: URL, in engine: Engine) async throws
}
