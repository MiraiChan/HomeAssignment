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
        .onChange(of: viewModel.pickedItem) {
          Task {
            if let _ = try? await viewModel.loadPickedImage() {
              showingEditor = true
            }
          }
        }
      
      if viewModel.editedScene != nil {
        Button("Restore Last Edited") {
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
