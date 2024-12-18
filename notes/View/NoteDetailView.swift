import SwiftUI
import PencilKit

struct NoteDetailView: View {
    let note: Note

    var body: some View {
        VStack {
            if note.type == .text  {
                Text(note.content ?? "No Content")
                    .padding()
            } else if note.type == .checklist {
                ChecklistView(items: note.checklistItems ?? [])
            } else if note.type == .drawing,
                      let data = note.drawingData,
                      let drawing = try? PKDrawing(data: data) {
                CanvasViewWrapper(drawing: drawing)
                    .frame(height: 300)
            } else {
                Text("Unsupported note type")
                    .padding()
            }
        }
        .navigationTitle(note.title)
    }
}

struct CanvasViewWrapper: UIViewRepresentable {
    let drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.drawingPolicy = .anyInput
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}

struct ChecklistView: View {
    @State private var checklistItems: [ChecklistItem]

    init(items: [ChecklistItem]) {
        _checklistItems = State(initialValue: items)
    }

    var body: some View {
        List {
            ForEach(checklistItems) { item in
                HStack {
                    Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                        .onTapGesture {
                            toggleCheckmark(for: item)
                        }
                    Text(item.text)
                }
            }
        }
        .padding()
    }

    func toggleCheckmark(for item: ChecklistItem) {
        if let index = checklistItems.firstIndex(where: { $0.id == item.id }) {
            checklistItems[index].isChecked.toggle()
        }
    }
}
