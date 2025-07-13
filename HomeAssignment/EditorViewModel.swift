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
  
  @Published var exportWidth: Int = 4096
  @Published var exportHeight: Int = 4096
  @Published var isRestoring = false

  private let scenePersistence: ScenePersistenceProtocol
  private let imageSaver: ImageSaverProtocol
  private let imagePickerService: ImagePickerServiceProtocol
  private var isExporting = false
  
  let engineSettings = EngineSettings(
    license: "5w31N62nDi7u0gw_GJij_EfB9db27f1QDUjltWvGopkeqA9A-hnPyIOwJgP70W4p",
    userID: "demo-user"
  )
  
  init(
    scenePersistence: ScenePersistenceProtocol = DefaultScenePersistenceService(),
    imageSaver: ImageSaverProtocol = PhotoLibraryService(),
    imagePickerService: ImagePickerServiceProtocol = DefaultImagePickerService()
  ) {
    self.scenePersistence = scenePersistence
    self.imageSaver = imageSaver
    self.imagePickerService = imagePickerService
  }
  
  func loadImageFromPickerItem() async throws -> URL? {
    let url = try await imagePickerService.loadPickedImage(from: pickedItem)
    pickedImageURL = url
    return url
  }
  func saveEdited(imageData: Data, sceneString: String) async throws {
    print("🟢 saveEdited started")
    
    guard let localId = try await imageSaver.saveImageToGallery(imageData) else { return }
    let sceneURL = try scenePersistence.saveSceneString(sceneString)
    editedScene = EditedImageSceneModel(assetLocalIdentifier: localId, sceneURL: sceneURL)
    
    print("🟢 saveEdited finished")
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
  
  // MARK: - Export Lock
  
  func startExport() -> Bool {
    if isExporting {
      return false
    } else {
      isExporting = true
      return true
    }
  }
  
  func finishExport() {
    isExporting = false
  }
}
