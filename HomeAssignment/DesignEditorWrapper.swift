//
//  DesignEditorWrapper.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 11.07.25.
import SwiftUI
import IMGLYDesignEditor
import IMGLYEngine

struct DesignEditorWrapper: UIViewControllerRepresentable {
  @ObservedObject var viewModel: EditorViewModel
  
  func makeUIViewController(context: Context) -> UINavigationController {
    let settings = viewModel.engineSettings
    
    let editor = DesignEditor(settings)
      .imgly.onCreate { engine in
        try await engine.addDefaultAssetSources()
        
        if let sceneURL = viewModel.editedScene?.sceneURL {
          do {
            let sceneString = try String(contentsOf: sceneURL)
            try await engine.scene.load(from: sceneString)
          } catch {
            print("Ошибка загрузки сцены: \(error)")
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
          }
        } else if let imageURL = viewModel.pickedImageURL {
          try await viewModel.applyImage(imageURL, in: engine)
        } else {
          let scene = try engine.scene.create()
          let page = try engine.block.create(.page)
          try engine.block.appendChild(to: scene, child: page)
        }
      }
      .imgly.onExport { engine, eventHandler in
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
        
        await MainActor.run {
          Task {
            try await viewModel.saveEdited(imageData: data, sceneString: sceneString)
            
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("export.png")
            try data.write(to: url)
            
            eventHandler.send(.shareFile(url))
          }
        }
      }
    
    // UIHostingController с редактором
    let editorVC = UIHostingController(rootView: editor)
    editorVC.navigationItem.title = "Editor"
    
    // Пустой root контроллер для навигации
    let rootVC = UIViewController()
    rootVC.view.backgroundColor = .systemBackground
    
    // Навигационный контроллер с двумя VC
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
  
  class Coordinator: NSObject, UINavigationControllerDelegate {
    weak var controller: UIViewController?
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
      if navigationController.viewControllers.count == 1 {
        controller?.dismiss(animated: true)
      }
    }
  }
}
