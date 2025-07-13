//
//  SceneBuilderProtocol.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 14.07.25.
//

import Foundation
import IMGLYEngine

protocol SceneBuilderProtocol {
  func applyImage(_ url: URL, in engine: Engine) async throws
}
