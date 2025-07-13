//
//  DefaultSceneBuilderService.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 14.07.25.
//
import Foundation
import IMGLYEngine
import os.log

struct DefaultSceneBuilderService: SceneBuilderProtocol {
  func applyImage(_ url: URL, in engine: Engine) async throws {
     if try await engine.scene.get() == nil {
       let scene = try await engine.scene.create()
      let page = try await engine.block.create(.page)
      try await engine.block.appendChild(to: scene, child: page)
    }
    
    guard let page = try await engine.block.find(byType: .page).first else {
      assertionFailure("❌ Page not found in scene. Creating fallback page.")
      let page = try await engine.block.create(.page)
      let scene = try await engine.scene.get()!
      try await engine.block.appendChild(to: scene, child: page)
      return
    }
    
    let block = try await engine.block.create(.graphic)
    let fill = try await engine.block.createFill(.image)
    try await engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try await engine.block.setFill(block, fill: fill)
    try await engine.block.setString(fill, property: "fill/image/imageFileURI", value: url.absoluteString)
    try await engine.block.setEnum(block, property: "contentFill/mode", value: "Contain")
    try await engine.block.appendChild(to: page, child: block)
    try await engine.scene.zoom(to: page)
  }
}
