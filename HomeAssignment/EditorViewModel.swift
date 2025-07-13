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
  private var isExporting = false
  
  let engineSettings = EngineSettings(
    license: "5w31N62nDi7u0gw_GJij_EfB9db27f1QDUjltWvGopkeqA9A-hnPyIOwJgP70W4p",
    userID: "demo-user"
  )
  
  init(
    scenePersistence: ScenePersistenceProtocol = DefaultScenePersistenceService(),
    imageSaver: ImageSaverProtocol = PhotoLibraryService(),
    imagePickerService: ImagePickerServiceProtocol = DefaultImagePickerService(),
    sceneBuilder: SceneBuilderProtocol = DefaultSceneBuilderService()
  ) {
    self.scenePersistence = scenePersistence
    self.imageSaver = imageSaver
    self.imagePickerService = imagePickerService
    self.sceneBuilder = sceneBuilder
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
  func applyImageToEngine(_ url: URL, engine: Engine) async throws {
    try await sceneBuilder.applyImage(url, in: engine)
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
