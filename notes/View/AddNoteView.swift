import SwiftUI
import PencilKit
import UIKit

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: NotesViewModel

    var existingNote: Note? = nil
    @State private var selectedType: Note.NoteType
    @State private var textContent: String = ""
    @State private var canvas = PKCanvasView()
    @State private var title: String = ""
    @State private var showTitleSheet: Bool = false
    @State private var tempTitle: String = ""
    @State private var showDeleteConfirmation: Bool = false
    @State private var checklistItems: [ChecklistItem] = []
    @State private var newChecklistText: String = ""
    @State private var fontSize: CGFloat = 14
    @State private var textColor: UIColor = .black
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var isUnderlined: Bool = false
    @State private var textAlignment: TextAlignment = .leading
    @State private var keyboardOffset: CGFloat = 0 // Nueva propiedad para el teclado

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

                    GeometryReader { geometry in
                        VStack {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.55) // Ajusté la altura para que sea más corta
                                    .shadow(radius: 5)
                                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.4) // Ajusté la posición vertical para que la hoja esté más cerca de la parte superior

                                if selectedType == .text {
                                    TextEditor(text: $textContent)
                                        .font(.system(size: fontSize, weight: isBold ? .bold : .regular, design: .default))
                                        .foregroundColor(Color(textColor))
                                        .italic(isItalic)
                                        .underline(isUnderlined)
                                        .multilineTextAlignment(textAlignment)
                                        .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.45) // Ajusté la altura para que sea más corta
                                        .padding(10)
                                        .background(Color.clear)
                                        .cornerRadius(10)
                                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.4) // Ajusté la posición vertical
                                }
                            }

                            Spacer()

                            HStack {
                                Button(action: { isBold.toggle() }) {
                                    Image(systemName: "bold")
                                        .foregroundColor(isBold ? .blue : .black)
                                }

                                Button(action: { isItalic.toggle() }) {
                                    Image(systemName: "italic")
                                        .foregroundColor(isItalic ? .blue : .black)
                                }

                                Button(action: { isUnderlined.toggle() }) {
                                    Image(systemName: "underline")
                                        .foregroundColor(isUnderlined ? .blue : .black)
                                }

                                Button(action: { textAlignment = .leading }) {
                                    Image(systemName: "text.alignleft")
                                }
                                Button(action: { textAlignment = .center }) {
                                    Image(systemName: "text.aligncenter")
                                }
                                Button(action: { textAlignment = .trailing }) {
                                    Image(systemName: "text.alignright")
                                }
                                Button(action: {
                                    if fontSize > 8 {
                                        fontSize -= 2
                                    }
                                }) {
                                    Image(systemName: "minus.magnifyingglass")
                                        .padding(8)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(5)
                                }

                                Button(action: {
                                    if fontSize < 50 {
                                        fontSize += 2
                                    }
                                }) {
                                    Image(systemName: "plus.magnifyingglass")
                                        .padding(8)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(5)
                                }

                                ColorPicker("", selection: Binding(
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
                        .onAppear {
                            if let note = existingNote {
                                title = note.title
                                textContent = note.content
                                selectedType = note.type
                                fontSize = note.fontSize
                                isBold = note.isBold
                                isItalic = note.isItalic
                                textColor = .black
                                isUnderlined = note.isUnderlined
                                textAlignment = note.textAlignment?.textAlignment ?? .leading
                            }

                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                                    withAnimation {
                                        keyboardOffset = keyboardFrame.height
                                    }
                                }
                            }

                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                                withAnimation {
                                    keyboardOffset = 0
                                }
                            }
                        }
                        .onDisappear {
                            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
                        }
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
                    ScrollView {
                        VStack(spacing: 16) {
                            TextField("Note title", text: $tempTitle)
                                .padding(10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            HStack {
                                Button("Cancel") {
                                    showTitleSheet = false
                                }
                                .padding(.vertical, 8)

                                Spacer(minLength: 16)

                                Button("Save") {
                                    title = tempTitle.isEmpty ? title : tempTitle
                                    showTitleSheet = false
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding()
                    }
                    .presentationDetents([.fraction(0.13)])
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
        }

    private func saveNote() {
        if let note = existingNote {
            viewModel.updateNote(note: note,
                                 title: title,
                                 content: textContent,
                                 type: selectedType,
                                 drawingData: canvas.drawing.dataRepresentation(), checklistItems: checklistItems,
                                 fontSize: fontSize,
                                 textColor: textColor.toHex() ?? "#000000",
                                 isBold: isBold,
                                 isItalic: isItalic,
                                 isUnderlined: isUnderlined,
                                 textAlignment: TextAlignmentWrapper(textAlignment: textAlignment)
            )
        } else {
            let newNote = Note(
                id: UUID(),
                title: title,
                content: textContent,
                type: selectedType,
                checklistItems: checklistItems,
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

        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}


