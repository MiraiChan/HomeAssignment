//
//  DesignEditorWrapper.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 11.07.25.
//
import SwiftUI
import IMGLYDesignEditor
import IMGLYEngine

struct DesignEditorWrapper: UIViewControllerRepresentable {
  @ObservedObject var viewModel: EditorViewModel
  
  func makeUIViewController(context: Context) -> UINavigationController {
    let settings = viewModel.engineSettings
    
    let editor = DesignEditor(settings)
      .imgly.onCreate { engine in
//        if let bundleURL = Bundle.main.url(forResource: "IMGLYAssets", withExtension: "bundle") {
//          print("Bundle URL: \(bundleURL)")
//          try await engine.addDefaultAssetSources(baseURL: bundleURL)
//        } else {
//          print("IMGLYAssets.bundle not found in main bundle!")
//        }
       try await engine.addDefaultAssetSources()

        
        if let sceneURL = viewModel.editedScene?.sceneURL {
          do {
            try await engine.scene.load(from: sceneURL)
          } catch {
            print("Ошибка загрузки сцены: \(error)")
            // Создаём новую сцену если загрузка не удалась
            let scene = try engine.scene.create()
            let page = try engine.block.create(.page)
            try engine.block.appendChild(to: scene, child: page)
          }
        } else if let imageURL = viewModel.pickedImageURL {
          try await viewModel.applyImage(imageURL, in: engine)
        } else {
          // Нет сцены и изображения — создаём пустую сцену с страницей
          let scene = try engine.scene.create()
          let page = try engine.block.create(.page)
          try engine.block.appendChild(to: scene, child: page)
        }
      }

      .imgly.onExport { engine, eventHandler in
        guard let scene = try engine.scene.get() else {
          throw NSError(domain: "No scene", code: 0)
        }
        
        let data = try await engine.block.export(scene, mimeType: .png) { backgroundEngine in
          // подготовка backgroundEngine
        }
        
        let sceneBlob = try await engine.scene.saveToArchive()
        
        // Здесь надо await, потому что MainActor.run — async
        await MainActor.run {
          Task {
            try await viewModel.saveEdited(imageData: data, sceneData: sceneBlob)
            
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("export.png")
            try data.write(to: url)
            
            eventHandler.send(.shareFile(url))
          }
        }
      }
    
    let controller = UIHostingController(rootView: editor)
    return UINavigationController(rootViewController: controller)
  }
  
  func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
