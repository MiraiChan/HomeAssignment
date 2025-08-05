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
// Main ViewModel holding app state and handling business logic for editor
@MainActor
class EditorViewModel: ObservableObject {
  @Published var pickedItem: PhotosPickerItem?         // Current picked photo item
  @Published var pickedImageURL: URL?                 // URL to picked image file
  @Published var editedScene: EditedImageSceneModel? // Saved edited scene info
  
  @Published var exportWidth: Int = 4096           // Export image width
  @Published var exportHeight: Int = 4096         // Export image height
  @Published var isRestoring = false             // Flag to restore last scene
  
  @Published var didExportSuccessfully = false
  
  // Services implementing required protocols for modularity and testing
  private let scenePersistence: ScenePersistenceProtocol
  private let imageSaver: ImageSaverProtocol
  private let imagePickerService: ImagePickerServiceProtocol
  private let sceneBuilder: SceneBuilderProtocol
  private let sceneRestorationService: SceneRestorationServiceProtocol
  
  private var isExporting = false // Prevent multiple exports at once
  // Settings needed for the IMGLY editing engine (license and user ID)
  let engineSettings = EngineSettings(
    license: "<insert your lisense key>",
    userID: "demo-user"
  )
  // Initialize with default services, can be replaced for testing.
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
  // Loads picked image from picker item, sets pickedImageURL
  func loadImageFromPickerItem() async throws -> URL? {
    let url = try await imagePickerService.loadPickedImage(from: pickedItem)
    pickedImageURL = url
    return url
  }
  // Saves edited image data and scene string, updates editedScene model
  func saveEdited(imageData: Data, sceneString: String) async throws {
    guard let localId = try await imageSaver.saveImageToGallery(imageData) else { return }
    let sceneURL = try scenePersistence.saveSceneString(sceneString)
    editedScene = EditedImageSceneModel(assetLocalIdentifier: localId, sceneURL: sceneURL)
  }
  // Applies a picked image to the editing engine scene
  func applyImageToEngine(_ url: URL, engine: Engine) async throws {
    try await sceneBuilder.applyImage(url, in: engine)
  }
  // Creates an empty scene with one page in the editing engine
  func createEmptyScene(in engine: Engine) async throws {
    let scene = try engine.scene.create()
    let page = try engine.block.create(.page)
    try engine.block.appendChild(to: scene, child: page)
  }
  // Restores the saved scene into the editing engine if requested
  func restoreSceneIfNeeded(in engine: Engine) async throws {
    if isRestoring, let sceneURL = editedScene?.sceneURL {
      try await sceneRestorationService.restoreScene(from: sceneURL, in: engine)
    }
  }
  // Marks the start of export process; prevents concurrent exports.
  func startExport() -> Bool {
    guard !isExporting else { return false }
    isExporting = true
    return true
  }
  // Marks export process finished, allowing next export.
  func finishExport() {
    isExporting = false
  }
}

extension EditorViewModel {
  func onCreate(engine: Engine) async throws {
//     if let bundleURL = Bundle.main.url(forResource: "IMGLYAssets", withExtension: "bundle") {
//     print("Bundle URL: \(bundleURL)")
//     try await engine.addDefaultAssetSources(baseURL: bundleURL)
//     } else {
//     print("IMGLYAssets.bundle not found in main bundle!")
//     }
    try await engine.addDefaultAssetSources()
    if isRestoring {
      try await restoreSceneIfNeeded(in: engine)
    } else if let url = pickedImageURL {
      try await applyImageToEngine(url, engine: engine)
    } else {
      try await createEmptyScene(in: engine)
    }
    //Force loading of resources
    if let scene = try engine.scene.get() {
      try await engine.block.forceLoadResources([scene])
    }
    //engine.editor.setEditMode(.text)
  }
  
  func onExport(engine: Engine) async throws {
    guard startExport() else { return }
    defer { finishExport() }
    
    guard let scene = try engine.scene.get() else {
      throw NSError(domain: "No scene", code: 0)
    }
    
    let options = ExportOptions(
      pngCompressionLevel: 3,
      targetWidth: Float(exportWidth),
      targetHeight: Float(exportHeight)
    )
    
    let data = try await engine.block.export(scene, mimeType: .png, options: options)
    let sceneString = try await engine.scene.saveToString()
    try await saveEdited(imageData: data, sceneString: sceneString)
    
    didExportSuccessfully = true
  }
}
