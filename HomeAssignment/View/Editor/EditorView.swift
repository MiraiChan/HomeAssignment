//
//  EditorView.swift
//  HomeAssignment
//
//  Created by Almira Khafizova on 19.07.25.
//

import SwiftUI
import IMGLYDesignEditor
import IMGLYEngine

struct EditorView: View {
  //a property in the view that "observes" the EditorViewModel object. The EditorViewModel is an ObservableObject, meaning it can report its changes.When the @Published variables inside the EditorViewModel are updated (for example, pickedImageURL, isRestoring, editedScene), SwiftUI will redraw this View.
  @ObservedObject var viewModel: EditorViewModel
  //SwiftUI's built—in reactive communication: A way to access the system's "close modal screen" (or full screen cover) function.Dismiss() is a function that will close the current View if it has been shown
  @Environment(\.dismiss) var dismiss
  @State private var showExportSuccessAlert = false
  
  var body: some View {
    DesignEditor(viewModel.engineSettings)
      .imgly.onCreate { engine in
        do {
          try await viewModel.onCreate(engine: engine)
        } catch {
          assertionFailure("Error on create: \(error.localizedDescription)")
        }
      }
      .imgly.onExport { engine, _ in
        Task {
          do {
            try await viewModel.onExport(engine: engine)
          } catch {
            assertionFailure("Export failed: \(error.localizedDescription)")
          }
        }
      }
      .onChange(of: viewModel.didExportSuccessfully) {
        if viewModel.didExportSuccessfully {
          showExportSuccessAlert = true
          viewModel.didExportSuccessfully = false
        }
      }
      .alert("Your image was saved successfully", isPresented: $showExportSuccessAlert) {
        Button("OK", role: .cancel) {
          dismiss()
        }
      }
  }
}
