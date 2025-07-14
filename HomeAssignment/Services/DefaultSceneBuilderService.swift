//
//  DefaultSceneBuilderService.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 14.07.25.
//
import Foundation
import IMGLYEngine
// Default implementation of scene builder service.
// Sets up the editing engine's scene with a new image.
struct DefaultSceneBuilderService: SceneBuilderProtocol {
  func applyImage(_ url: URL, in engine: Engine) async throws {
    // If there's no current scene, create a new one with a page block
    if try await engine.scene.get() == nil {
      let scene = try await engine.scene.create()
      let page = try await engine.block.create(.page)
      try await engine.block.appendChild(to: scene, child: page)
    }
    // Find the first page block in the scene
    guard let page = try await engine.block.find(byType: .page).first else {
      // If no page found, create fallback page and add it to scene
      assertionFailure("❌ Page not found in scene. Creating fallback page.")
      let page = try await engine.block.create(.page)
      let scene = try await engine.scene.get()!
      try await engine.block.appendChild(to: scene, child: page)
      return
    }
    // Create a graphic block and fill it with the image from URL
    let block = try await engine.block.create(.graphic)
    let fill = try await engine.block.createFill(.image)
    try await engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try await engine.block.setFill(block, fill: fill)
    // Set the image URL as the source of the fill
    try await engine.block.setString(fill, property: "fill/image/imageFileURI", value: url.absoluteString)
    // Set how the image fits into the block (contain mode)
    try await engine.block.setEnum(block, property: "contentFill/mode", value: "Contain")
    // Add the graphic block as a child to the page
    try await engine.block.appendChild(to: page, child: block)
    // Zoom the editor view to show the page
    try await engine.scene.zoom(to: page)
  }
}
