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
  private let sceneBuilder: SceneBuilderProtocol
  private let sceneRestorationService: SceneRestorationServiceProtocol
  
  private var isExporting = false
  
  let engineSettings = EngineSettings(
    license: "<insert your lisense key>",
    userID: "demo-user"
  )
  
  init(
    scenePersistence: ScenePersistenceProtocol = DefaultScenePersistenceService(),
    imageSaver: ImageSaverProtocol = PhotoLibraryService(),
    imagePickerService: ImagePickerServiceProtocol = DefaultImagePickerService(),
    sceneBuilder: SceneBuilderProtocol = DefaultSceneBuilderService(),
    sceneRestorationService: SceneRestorationServiceProtocol = DefaultSceneRestorationService()
  ) {
    self.scenePersistence = scenePersistence
    self.imageSaver = imageSaver
    self.imagePickerService = imagePickerService
    self.sceneBuilder = sceneBuilder
    self.sceneRestorationService = sceneRestorationService
  }
  
  func loadImageFromPickerItem() async throws -> URL? {
    let url = try await imagePickerService.loadPickedImage(from: pickedItem)
    pickedImageURL = url
    return url
  }
  
  func saveEdited(imageData: Data, sceneString: String) async throws {
    guard let localId = try await imageSaver.saveImageToGallery(imageData) else { return }
    let sceneURL = try scenePersistence.saveSceneString(sceneString)
    editedScene = EditedImageSceneModel(assetLocalIdentifier: localId, sceneURL: sceneURL)
  }
  
  func applyImageToEngine(_ url: URL, engine: Engine) async throws {
    try await sceneBuilder.applyImage(url, in: engine)
  }
  
  func createEmptyScene(in engine: Engine) async throws {
    let scene = try engine.scene.create()
    let page = try engine.block.create(.page)
    try engine.block.appendChild(to: scene, child: page)
  }
  
  func restoreSceneIfNeeded(in engine: Engine) async throws {
    if isRestoring, let sceneURL = editedScene?.sceneURL {
      try await sceneRestorationService.restoreScene(from: sceneURL, in: engine)
    }
  }
  
  func startExport() -> Bool {
    guard !isExporting else { return false }
    isExporting = true
    return true
  }
  
  func finishExport() {
    isExporting = false
  }
}
