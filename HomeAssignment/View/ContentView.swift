//
//  ContentView.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 10.07.25.
//

import SwiftUI
import PhotosUI
import IMGLYDesignEditor
// Main app view showing image picker and restore button.
struct ContentView: View {
  @StateObject private var viewModel = EditorViewModel()
  @State private var showingEditor = false
  
  var body: some View {
    VStack(spacing: 20) {
      // Button to pick a photo from the library
      PhotosPicker("Choose Image", selection: $viewModel.pickedItem, matching: .images)
        .onChange(of: viewModel.pickedItem) {
          Task {
            // When image is picked, load it and open editor
            if let url = try? await viewModel.loadImageFromPickerItem() {
              viewModel.pickedImageURL = url
              viewModel.isRestoring = false
              showingEditor = true
            }
          }
        }
      // Show "Restore Last Edited" button if a saved scene exists
      if viewModel.editedScene != nil {
        Button("Restore Last Edited") {
          viewModel.isRestoring = true
          showingEditor = true
        }
      }
    }
    // Present the editor in full screen when needed
    .fullScreenCover(isPresented: $showingEditor) {
      //navigation context for DesignEditor
      NavigationView {
        //customizable editor view, built on the basis of DesignEditor
        EditorView(viewModel: viewModel)
      }
      //The CE.SDK requires the DesignEditor to be inside the stack-based NavigationView, otherwise the toolbars will not appear.
      .navigationViewStyle(.stack)
    }
  }
}

#Preview {
  ContentView()
}
