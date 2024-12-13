import SwiftUI
import PencilKit
import UIKit

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: NotesViewModel

    // Parámetro opcional para editar una nota existente
    var existingNote: Note? = nil

    @State private var selectedType: Note.NoteType
    @State private var textContent: String = ""
    @State private var canvas = PKCanvasView()
    @State private var title: String = ""
    @State private var showTitleSheet: Bool = false
    @State private var tempTitle: String = ""
    @State private var showDeleteConfirmation: Bool = false // Flag para mostrar la confirmación

    // Variables de estilo de texto
    @State private var fontSize: CGFloat = 14
    @State private var textColor: UIColor = .black
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var isUnderlined: Bool = false
    @State private var textAlignment: TextAlignment = .leading

    init(viewModel: NotesViewModel, existingNote: Note? = nil, selectedType: Note.NoteType = .text) {
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
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.7)
                            .shadow(radius: 5)

                        // Mostrar contenido según el tipo de nota
                        if selectedType == .text || selectedType == .checklist {
                            TextEditor(text: $textContent)
                                .font(.system(size: fontSize, weight: isBold ? .bold : .regular, design: .default))
                              //  .foregroundColor(Color(textColor)) // Convertir UIColor a Color
                                .italic(isItalic)
                                .underline(isUnderlined)
                                .multilineTextAlignment(textAlignment)
                                .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.65)
                                .padding(10)
                                .background(Color.clear)
                                .cornerRadius(10)

                        } else if selectedType == .drawing {
                            CanvasView(canvas: $canvas, color: .constant(.black), type: .constant(.pencil), isDraw: .constant(true))

                                .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.65)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                        }
                    }

                    Spacer()

                    // Controles para el estilo de texto
                    HStack {
                        // Botón de Negrita
                        Button(action: { isBold.toggle() }) {
                            Image(systemName: "bold")
                                .foregroundColor(isBold ? .blue : .black)
                        }

                        // Botón de Cursiva
                        Button(action: { isItalic.toggle() }) {
                            Image(systemName: "italic")
                                .foregroundColor(isItalic ? .blue : .black)
                        }

                        // Botón de Subrayado
                        Button(action: { isUnderlined.toggle() }) {
                            Image(systemName: "underline")
                                .foregroundColor(isUnderlined ? .blue : .black)
                        }

                        // Botones para alineación de texto
                       Button(action: { textAlignment = .leading }) {
                           Image(systemName: "text.alignleft")
                       }
                       Button(action: { textAlignment = .center }) {
                           Image(systemName: "text.aligncenter")
                       }
                       Button(action: { textAlignment = .trailing }) {
                           Image(systemName: "text.alignright")
                       }

                        // Controles para el tamaño de texto
                        Button(action: {
                            if fontSize > 8 { // Limitar tamaño mínimo
                                fontSize -= 2
                            }
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }

                        Button(action: {
                            if fontSize < 50 { // Limitar tamaño máximo
                                fontSize += 2
                            }
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }

                        // Selector de color de texto
                      ColorPicker(" ", selection: Binding(
                          get: {
                              Color(self.textColor)
                          },
                          set: { newColor in
                              self.textColor = UIColor(newColor)
                          }
                      ))
                        .frame(width: 50, height: 50)
                    }
                    .padding()
                }
            }

            // Barra de herramientas
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

                // Agregar el botón de borrar
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

            // Hoja para editar el título
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

            // Confirmación para borrar la nota
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("¿Estás seguro de que quieres eliminar esta nota?"),
                    message: Text("Esta acción no se puede deshacer."),
                    primaryButton: .destructive(Text("Eliminar")) {
                        if let note = existingNote {
                            viewModel.deleteNote(note: note)
                            dismiss() // Cerrar la vista tras eliminar
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
                fontSize = note.fontSize
                isBold = note.isBold
                isItalic = note.isItalic
                isUnderlined = note.isUnderlined
                textAlignment = note.textAlignment?.textAlignment ?? .leading
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
            // Actualizar la nota existente
            viewModel.updateNote(note: note,
                                 title: title,
                                 content: textContent,
                                 type: selectedType,
                                 drawingData: canvas.drawing.dataRepresentation(),
                                 fontSize: fontSize,
                                 textColor: textColor.toHex() ?? "#000000",
                                 isBold: isBold,
                                 isItalic: isItalic,
                                 isUnderlined: isUnderlined,
                                 textAlignment: TextAlignmentWrapper(textAlignment: textAlignment)
            )
        } else {
            // Crear una nueva nota
            let newNote = Note(
                id: UUID(),
                title: title,
                content: textContent,
                type: selectedType,
                drawingData: canvas.drawing.dataRepresentation(),
                fontSize: fontSize,
                textColor: textColor.toHex() ?? "#000000",
                isBold: isBold,
                isItalic: isItalic,
                isUnderlined: isUnderlined,
                textAlignment: TextAlignmentWrapper(textAlignment: textAlignment)
            )
            viewModel.addNote(note: newNote)
        }
    }

    
}



extension UIColor {
    func toHex() -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
