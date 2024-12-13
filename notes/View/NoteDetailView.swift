
import SwiftUI
import PencilKit

struct NoteDetailView: View {
    let note: Note

    var body: some View {
        VStack {
            if note.type == .text || note.type == .checklist {
                Text(note.content ?? "Sin contenido")
                    .padding()
            } else if note.type == .drawing,
                      let data = note.drawingData,
                      let drawing = try? PKDrawing(data: data) {
                CanvasViewWrapper(drawing: drawing)
                    .frame(height: 300)
            } else {
                Text("Tipo de nota no soportado")
                    .padding()
            }
        }
        .navigationTitle(note.title)
    }
}

// Un contenedor para inicializar PKCanvasView con un PKDrawing
struct CanvasViewWrapper: UIViewRepresentable {
    let drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.drawingPolicy = .anyInput
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Actualiza el canvas si es necesario
    }
}


