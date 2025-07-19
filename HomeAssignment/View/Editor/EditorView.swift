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
  
  var body: some View {
    DesignEditor(viewModel.engineSettings)
      .imgly.onCreate { engine in
        try await viewModel.onCreate(engine: engine)
      }
      .imgly.onExport { engine, _ in
        try await viewModel.onExport(engine: engine)
        dismiss()
      }
      .navigationBarTitle("Editor", displayMode: .inline)
  }
}
