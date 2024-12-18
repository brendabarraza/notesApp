import SwiftUI
import PencilKit

struct AddNoteDraw: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: NotesViewModel

    var existingNote: Note? = nil

    @State private var selectedType: Note.NoteType
    @State private var textContent: String = ""
    @State private var canvas = PKCanvasView()
    @State private var title: String = ""
    @State private var showTitleSheet: Bool = false
    @State private var tempTitle: String = ""
    @State private var textAlignment: TextAlignment = .leading
    @State private var color: Color = .black
    @State private var type: PKInkingTool.InkType = .pencil
    @State private var isDraw: Bool = true
    @State private var textColor: UIColor = .black
    @State private var checklistItems: [ChecklistItem] = []
    @State private var showDeleteConfirmation: Bool = false
    init(viewModel: NotesViewModel, existingNote: Note? = nil, selectedType: Note.NoteType = .drawing) {
        self.viewModel = viewModel
        self.existingNote = existingNote
        _selectedType = State(initialValue: selectedType)
    }

    var body: some View {
        VStack {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()

                VStack {
                    ZStack(alignment: .topLeading) {
                        if selectedType == .text || selectedType == .checklist {
                            TextEditor(text: $textContent)
                                .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.65)
                                .padding(10)
                                .foregroundColor(.black)
                                .background(Color.clear)
                                .cornerRadius(10)
                        } else if selectedType == .drawing {
                            VStack {
                                CanvasView(canvas: $canvas, color: $color, type: $type, isDraw: $isDraw)
                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.7)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                HStack {
                                    ColorPicker("", selection: $color)
                                    BotonView(action: { type = .pencil }, icon: "pencil")
                                    BotonView(action: { type = .pen }, icon: "pencil.tip")
                                    BotonView(action: { type = .marker }, icon: "highlighter")
                                    BotonView(action: { isDraw.toggle() }, icon: "pencil.slash")
                                    BotonView(action: { canvas.drawing = PKDrawing() }, icon: "trash")
                                    BotonView(action: { saveImage() }, icon: "square.and.arrow.down.fill")
                                }
                                .padding()
                            }
                        }
                    }
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        showTitleSheet = true
                    }) {
                        Text(title.isEmpty ? "New Note" : title)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if title.isEmpty {
                            showTitleSheet = true
                        } else {
                            saveNote()
                            dismiss()
                        }
                    }
                }
                if let note = existingNote {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .sheet(isPresented: $showTitleSheet) {
                VStack {
                    TextField("Note title", text: $tempTitle)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    HStack {
                        Button("Cancel") {
                            showTitleSheet = false
                        }
                        .padding()

                        Spacer()

                        Button("Save") {
                            title = tempTitle.isEmpty ? title : tempTitle
                            showTitleSheet = false
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Are you sure you want to delete this note?"),
                    message: Text("This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let note = existingNote {
                            viewModel.deleteNote(note: note)
                            dismiss()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            if let note = existingNote {
                title = note.title
                textContent = note.content
                selectedType = note.type
                if let drawingData = note.drawingData {
                    if let drawing = try? PKDrawing(data: drawingData) {
                        canvas.drawing = drawing
                    }
                }
            }
        }
    }

    private func saveNote() {
        if let note = existingNote {
            viewModel.updateNote(note: note, title: title, content: textContent, type: selectedType, drawingData: canvas.drawing.dataRepresentation(), checklistItems: checklistItems, fontSize: 0, textColor: textColor.toHex() ?? "#000000", isBold: false, isItalic: false, isUnderlined: false, textAlignment: nil)
        } else {
            let newNote = Note(
                id: UUID(),
                title: title,
                content: textContent,
                type: selectedType,
                drawingData: canvas.drawing.dataRepresentation(),
                fontSize: 0,
                textColor: textColor.toHex() ?? "#000000",
                isBold: false,
                isItalic: false,
                isUnderlined: false,
                textAlignment: nil
            )
            viewModel.addNote(note: newNote)
        }
    }

    private func saveImage() {
        let image = canvas.drawing.image(from: canvas.drawing.bounds, scale: 1)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

struct BotonView: View {
    var action: (() -> Void)
    var icon: String

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
        }
    }
}
