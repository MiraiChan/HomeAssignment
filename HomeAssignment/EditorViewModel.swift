//
//  EditorViewModel.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 11.07.25.
//
import Photos
import IMGLYEngine
import IMGLYDesignEditor
import _PhotosUI_SwiftUI

@MainActor
class EditorViewModel: ObservableObject {
  @Published var pickedItem: PhotosPickerItem?
  @Published var pickedImageURL: URL?
  @Published var editedScene: EditedImageSceneModel?
  
  // Добавляем свойства для размера экспорта
  @Published var exportWidth: Int = 4096
  @Published var exportHeight: Int = 4096
  
  let engineSettings = EngineSettings(
    license: "5w31N62nDi7u0gw_GJij_EfB9db27f1QDUjltWvGopkeqA9A-hnPyIOwJgP70W4p",
    userID: "demo-user"
  )
  
  func loadPickedImage() async throws -> URL? {
    guard let data = try await pickedItem?.loadTransferable(type: Data.self) else { return nil }
    let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("picked_image.jpg")
    try data.write(to: tmpURL)
    pickedImageURL = tmpURL
    return tmpURL
  }
  
  func saveImageToGallery(_ imageData: Data) async throws -> String? {
    var localId: String?
    try await PHPhotoLibrary.shared().performChanges {
      let request = PHAssetCreationRequest.forAsset()
      request.addResource(with: .photo, data: imageData, options: nil)
      localId = request.placeholderForCreatedAsset?.localIdentifier
    }
    return localId
  }
  
  func saveSceneString(_ sceneString: String) throws -> URL {
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let sceneURL = docs.appendingPathComponent("\(UUID().uuidString).scene")
    try sceneString.write(to: sceneURL, atomically: true, encoding: .utf8)
    return sceneURL
  }
  
  func saveEdited(imageData: Data, sceneString: String) async throws {
    guard let localId = try await saveImageToGallery(imageData) else { return }
    let sceneURL = try saveSceneString(sceneString)
    editedScene = EditedImageSceneModel(assetLocalIdentifier: localId, sceneURL: sceneURL)
  }
  
  func applyImage(_ url: URL, in engine: Engine) async throws {
    if try engine.scene.get() == nil {
      let scene = try engine.scene.create()
      let page = try engine.block.create(.page)
      try engine.block.appendChild(to: scene, child: page)
    }
    guard let page = try engine.block.find(byType: .page).first else {
      print("❌ Ошибка: страница не найдена в сцене")
      let page = try engine.block.create(.page)
      let scene = try engine.scene.get()!
      try engine.block.appendChild(to: scene, child: page)
      return
    }
    let block = try engine.block.create(.graphic)
    let fill = try engine.block.createFill(.image)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    try engine.block.setFill(block, fill: fill)
    try engine.block.setString(fill, property: "fill/image/imageFileURI", value: url.absoluteString)
    try engine.block.setEnum(block, property: "contentFill/mode", value: "Contain")
    try engine.block.appendChild(to: page, child: block)
    try await engine.scene.zoom(to: page)
  }
}
