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
        
        let data = try await engine.block.export(scene, mimeType: .png) { _ in }
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
    
    // Обёртка с кнопкой "Закрыть"
    let controller = UIHostingController(rootView:
                                          ZStack(alignment: .topLeading) {
      editor
      
      Button(action: {
        context.coordinator.dismiss()
      }) {
        Image(systemName: "xmark.circle.fill")
          .font(.system(size: 30))
          .padding()
          .foregroundColor(.white)
          .background(Color.black.opacity(0.3))
          .clipShape(Circle())
      }
      .padding()
    }
    )
    
    let nav = UINavigationController(rootViewController: controller)
    nav.modalPresentationStyle = .fullScreen
    context.coordinator.controller = nav
    return nav
  }
  
  func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  class Coordinator {
    weak var controller: UIViewController?
    
    func dismiss() {
      controller?.dismiss(animated: true)
    }
  }
}
