import SwiftUI

struct AddNoteCheck: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: NotesViewModel

    var existingNote: Note? = nil

    @State private var selectedType: Note.NoteType
    @State private var title: String = ""
    @State private var checklistItems: [ChecklistItem] = []
    @State private var newChecklistText: String = ""
    @State private var textContent: String = ""
    @State private var showTitleSheet: Bool = false
    @State private var tempTitle: String = ""
    @State private var color: Color = .black
    @State private var isDraw = true
    @State private var textAlignment: TextAlignment = .leading
    @State private var textColor: UIColor = .black
    
    init(viewModel: NotesViewModel, existingNote: Note? = nil, selectedType: Note.NoteType = .checklist) {
        self.viewModel = viewModel
        self.existingNote = existingNote
        _selectedType = State(initialValue: selectedType)
    }

    var body: some View {
        VStack {
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()

                VStack {
                    ZStack(alignment: .topLeading) {
                        if selectedType == .text || selectedType == .checklist {
                            // Lista interactiva para checklist o TextEditor para texto
                            if selectedType == .checklist {
                                ScrollView {
                                    VStack(alignment: .leading) {
                                        ForEach(checklistItems.indices, id: \.self) { index in
                                            Button(action: {
                                                checklistItems[index].isChecked.toggle()
                                            }) {
                                                HStack {
                                                    Image(systemName: checklistItems[index].isChecked ? "checkmark.square.fill" : "square")
                                                        .foregroundColor(checklistItems[index].isChecked ? .green : .gray)
                                                        .font(.title2)

                                                    TextField("Item", text: $checklistItems[index].text)
                                                }
                                                .padding()
                                                .background(Color(UIColor.systemGray6))
                                                .cornerRadius(8)
                                            }
                                        }
                                        .padding(.top, 10) // Ajusta el espacio superior de las notas.
                                    }
                                    .padding(100)
                                }

                                // Campo para añadir nuevos ítems al checklist
                                HStack {
                                    TextField("Añadir ítem...", text: $newChecklistText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal)

                                    Button(action: addChecklistItem) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                }
                                .padding(.top, 10) // Aumenta el espacio entre el campo de agregar y la lista.
                                .padding(.vertical)

                                .padding(.vertical)
                            } else if selectedType == .checklist {
                                VStack {
                                    ForEach(checklistItems) { item in
                                        HStack {
                                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(item.isChecked ? .green : .gray)
                                            Text(item.text)
                                                .font(.body)
                                            Spacer()
                                        }
                                        .padding()
                                        .onTapGesture {
                                            // Toggle completion status
                                            if let index = checklistItems.firstIndex(where: { $0.id == item.id }) {
                                                checklistItems[index].isChecked.toggle()
                                            }
                                        }
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.65)
                                .padding(10)
                                .background(Color.clear)
                                .cornerRadius(10)
                            }

                        }
                    }

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: { showTitleSheet = true }) {
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

                        Spacer()

                        Button("Guardar") {
                            title = tempTitle.isEmpty ? title : tempTitle
                            showTitleSheet = false
                        }
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
            
                if selectedType == .checklist {
                    checklistItems = parseChecklist(content: note.content)
                }
            }
        }
    }

    private func addChecklistItem() {
        guard !newChecklistText.isEmpty else { return }
        checklistItems.append(ChecklistItem(text: newChecklistText, isChecked: false))
        newChecklistText = ""
    }

    private func saveNote() {
        let content: String
        if selectedType == .checklist {
            content = checklistItems.map { "\($0.isChecked ? "[x]" : "[ ]") \($0.text)" }.joined(separator: "\n")
        } else {
            content = textContent
        }
        
        if let note = existingNote {
            viewModel.updateNote(note: note, title: title, content: content, type: selectedType, drawingData: nil, fontSize: 0, textColor: textColor.toHex() ?? "#000000", isBold: false, isItalic: false, isUnderlined: false, textAlignment: nil)
        } else {
            let newNote = Note(
                id: UUID(),
                title: title,
                content: content,
                type: selectedType,
                drawingData: nil,
                fontSize: 0,
                textColor: textColor.toHex() ?? "#000000",
                isBold: false,
                isItalic: false,
                isUnderlined: false
            )
            viewModel.addNote(note: newNote)
        }
    }

    private func parseChecklist(content: String) -> [ChecklistItem] {
        return content.split(separator: "\n").map { line in
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let isChecked = trimmedLine.starts(with: "[x]")
            let text = trimmedLine.replacingOccurrences(of: "[x]", with: "").replacingOccurrences(of: "[ ]", with: "").trimmingCharacters(in: .whitespaces)
            return ChecklistItem(text: text, isChecked: isChecked)
        }
    }
}

struct ChecklistItem: Identifiable {
    let id = UUID()
    var text: String
    var isChecked: Bool
}


