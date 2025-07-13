//
//  ContentView.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 10.07.25.
//

import SwiftUI
import PhotosUI
import IMGLYDesignEditor

struct ContentView: View {
  @StateObject private var viewModel = EditorViewModel()
  @State private var showingEditor = false
  
  var body: some View {
    VStack(spacing: 20) {
      PhotosPicker("Choose Image", selection: $viewModel.pickedItem, matching: .images)
        .onChange(of: viewModel.pickedItem) { _ in
          Task {
            if let _ = try? await viewModel.loadPickedImage() {
              viewModel.isRestoring = false
              showingEditor = true
            }
          }
        }
      
      if viewModel.editedScene != nil {
        Button("Restore Last Edited") {
          viewModel.isRestoring = true
          showingEditor = true
        }
      }
    }
    .fullScreenCover(isPresented: $showingEditor) {
      DesignEditorWrapper(viewModel: viewModel)
    }
  }
}

#Preview {
  ContentView()
}
