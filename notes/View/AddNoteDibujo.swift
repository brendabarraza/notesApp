import SwiftUI
import PencilKit

struct AddNoteDibujo: View {
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

    init(viewModel: NotesViewModel, existingNote: Note? = nil, selectedType: Note.NoteType = .drawing) {
        self.viewModel = viewModel
        self.existingNote = existingNote
        _selectedType = State(initialValue: selectedType)
    }

    var body: some View {
        VStack {
            ZStack {
                // Fondo general gris
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()

                VStack {
                    ZStack(alignment: .topLeading) {
                        // Cambiar diseño basado en el tipo de nota
                        if selectedType == .text || selectedType == .checklist {
                            TextEditor(text: $textContent)
                                .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.65)
                                .padding(10)
                                .foregroundColor(.black)
                                .background(Color.clear)
                                .cornerRadius(10)
                        } else if selectedType == .drawing {
                            VStack {
                                // Canvas directamente sobre el fondo
                                CanvasView(canvas: $canvas, color: $color, type: $type, isDraw: $isDraw)
                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.7)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                
                                // Herramientas de dibujo
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
                        Text(title.isEmpty ? "Nueva Nota" : title)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        if title.isEmpty {
                            showTitleSheet = true
                        } else {
                            saveNote()
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showTitleSheet) {
                VStack {
                    Text("Editar título de la nota")
                        .font(.subheadline)

                    TextField("Título de la nota", text: $tempTitle)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    HStack {
                        Button("Cancelar") {
                            showTitleSheet = false
                        }
                        .padding()

                        Spacer()

                        Button("Guardar") {
                            title = tempTitle.isEmpty ? title : tempTitle
                            showTitleSheet = false
                        }
                        .padding()
                    }
                }
                .padding()
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
            viewModel.updateNote(note: note, title: title, content: textContent, type: selectedType, drawingData: canvas.drawing.dataRepresentation(), fontSize: 0, textColor: textColor.toHex() ?? "#000000", isBold: false, isItalic: false, isUnderlined: false, textAlignment: nil)
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
