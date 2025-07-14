//
//  DesignEditorWrapper.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 11.07.25.

import SwiftUI
import IMGLYDesignEditor
import IMGLYEngine
import Photos

struct DesignEditorWrapper: UIViewControllerRepresentable {
  @ObservedObject var viewModel: EditorViewModel
  
  func makeUIViewController(context: Context) -> UINavigationController {
    let settings = viewModel.engineSettings
    let editor = DesignEditor(settings)
    
      .imgly.onCreate { engine in
        try await self.handleOnCreate(engine: engine)
      }
    
      .imgly.onExport { engine, eventHandler in
        Task {
          await self.handleOnExport(engine: engine, context: context)
        }
      }
    
    let editorVC = UIHostingController(rootView: editor)
    editorVC.navigationItem.title = "Editor"
    
    let rootVC = UIViewController()
    rootVC.view.backgroundColor = .systemBackground
    
    let nav = UINavigationController(rootViewController: rootVC)
    nav.pushViewController(editorVC, animated: false)
    nav.delegate = context.coordinator
    nav.modalPresentationStyle = .fullScreen
    context.coordinator.controller = nav
    return nav
  }
  
  func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  // MARK: - Private methods
  
  private func handleOnCreate(engine: Engine) async throws {
    try await engine.addDefaultAssetSources()
    if viewModel.isRestoring {
      try await viewModel.restoreSceneIfNeeded(in: engine)
    } else if let imageURL = viewModel.pickedImageURL {
      try await viewModel.applyImageToEngine(imageURL, engine: engine)
    } else {
      try await viewModel.createEmptyScene(in: engine)
    }
  }
  
  private func handleOnExport(engine: Engine, context: Context) async {
    guard viewModel.startExport() else {
      return
    }
    defer { viewModel.finishExport() }
    
    do {
      guard let scene = try engine.scene.get() else {
        throw NSError(domain: "No scene", code: 0)
      }
      
      let options = ExportOptions(
        pngCompressionLevel: 3,
        targetWidth: Float(viewModel.exportWidth),
        targetHeight: Float(viewModel.exportHeight)
      )
      
      let data = try await engine.block.export(scene, mimeType: .png, options: options)
      let sceneString = try await engine.scene.saveToString()
      
      try await viewModel.saveEdited(imageData: data, sceneString: sceneString)
      
      let url = FileManager.default.temporaryDirectory.appendingPathComponent("export.png")
      try data.write(to: url)

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
  
  class Coordinator: NSObject, UINavigationControllerDelegate {
    weak var controller: UIViewController?
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
      if navigationController.viewControllers.count == 1 {
        controller?.dismiss(animated: true)
      }
    }
  }
}
