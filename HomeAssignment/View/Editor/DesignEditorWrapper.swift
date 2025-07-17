//
//  DesignEditorWrapper.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 11.07.25.

import SwiftUI
import IMGLYDesignEditor
import IMGLYEngine
import Photos
// Wrapper around the design editor UIKit controller to use in SwiftUI.
struct DesignEditorWrapper: UIViewControllerRepresentable {
  @ObservedObject var viewModel: EditorViewModel
  // Creates the UINavigationController that contains the editor UI.
  func makeUIViewController(context: Context) -> UINavigationController {
    let settings = viewModel.engineSettings
    let editor = DesignEditor(settings)
    
      .imgly.onCreate { engine in
        // Called when editor is created: initialize scene or restore if needed.
        do {
          try await self.handleOnCreate(engine: engine)
        } catch {
          assertionFailure("❌ Failed to initialize editor: \(error)")
        }
      }
    
      .imgly.onExport { engine, eventHandler in
        // Called when user exports the image from the editor.
        Task {
          do {
            try await self.handleOnExport(engine: engine, context: context)
          } catch {
            assertionFailure("❌ Export failed: \(error)")
          }
        }
      }
    // Wrap editor SwiftUI view in UIKit hosting controller for navigation.
    let editorVC = UIHostingController(rootView: editor)
    editorVC.navigationItem.title = "Editor"
    // Root controller just sets background color and navigation root.
    let rootVC = UIViewController()
    rootVC.view.backgroundColor = .systemBackground
    
    let nav = UINavigationController(rootViewController: rootVC)
    nav.pushViewController(editorVC, animated: false)
    nav.delegate = context.coordinator
    nav.modalPresentationStyle = .fullScreen
    // Keep reference to UINavigationController to dismiss later.
    context.coordinator.controller = nav
    return nav
  }
  // Required by protocol; no updates needed here.
  func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
  // Create coordinator for navigation delegate callbacks.
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  // MARK: - Private methods
  // Handles editor creation event: either restore scene, apply image, or create empty scene.
  private func handleOnCreate(engine: Engine) async throws {
    try await engine.addDefaultAssetSources()
    if viewModel.isRestoring {
      // Restore previously saved editing scene if requested
      try await viewModel.restoreSceneIfNeeded(in: engine)
    } else if let imageURL = viewModel.pickedImageURL {
      // If new image selected, apply it to editor engine
      try await viewModel.applyImageToEngine(imageURL, engine: engine)
    } else {
      // Otherwise create blank editing scene
      try await viewModel.createEmptyScene(in: engine)
    }
  }
  // Handles export event: saves image and scene, shows confirmation alert.
  private func handleOnExport(engine: Engine, context: Context) async throws {
    guard viewModel.startExport() else {
      // Prevent multiple exports at the same time
      return
    }
    defer { viewModel.finishExport() }
    
    do {
      guard let scene = try engine.scene.get() else {
        throw NSError(domain: "No scene", code: 0)
      }
      // Set export options: image size and compression
      let options = ExportOptions(
        pngCompressionLevel: 3,
        targetWidth: Float(viewModel.exportWidth),
        targetHeight: Float(viewModel.exportHeight)
      )
      // Export edited scene as PNG image data
      let data = try await engine.block.export(scene, mimeType: .png, options: options)
      // Save scene as string for future restoration
      let sceneString = try await engine.scene.saveToString()
      // Save both image and scene persistently
      try await viewModel.saveEdited(imageData: data, sceneString: sceneString)
      // Also write PNG data to a temporary file (optional)
      let url = FileManager.default.temporaryDirectory.appendingPathComponent("export.png")
      try data.write(to: url)
      // Show a simple alert confirming the image was saved
      await MainActor.run {
        viewModel.pickedImageURL = nil
        viewModel.isRestoring = false
        
        if let controller = context.coordinator.controller {
          let alert = UIAlertController(title: nil, message: "Your image is saved", preferredStyle: .alert)
          controller.present(alert, animated: true)
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
          }
        }
      }
    } catch {
      assertionFailure("❌ Export error: \(error)")
    }
  }
  // Coordinator handles navigation controller events such as back button.
  class Coordinator: NSObject, UINavigationControllerDelegate {
    weak var controller: UIViewController?
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
      if navigationController.viewControllers.count == 1 {
        // If user navigates back to root view, dismiss the editor modal.
        controller?.dismiss(animated: true)
      }
    }
  }
}
