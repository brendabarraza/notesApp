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
    @State private var showDeleteConfirmation: Bool = false
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
                        if selectedType == .checklist {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGray6))
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .padding(10)
                                .overlay(
                                    VStack {
                                        HStack {
                                            TextField("Add item...", text: $newChecklistText)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())

                                            Button(action: addChecklistItem) {
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.title2)
                                            }
                                        }
                                        .padding(.horizontal, 20) // Añade un margen horizontal al HStack completo
                                        .padding(.top, 10)
                                        .padding(.vertical)


                                        ScrollView {
                                            VStack(alignment: .leading) {
                                                ForEach(checklistItems.indices, id: \.self) { index in
                                                    HStack {
                                                        Button(action: {
                                                            checklistItems[index].isChecked.toggle()
                                                        }) {
                                                            HStack {
                                                                Image(systemName: checklistItems[index].isChecked ? "checkmark.square.fill" : "square")
                                                                    .foregroundColor(checklistItems[index].isChecked ? .green : .gray)
                                                                    .font(.title2)

                                                                TextField("Item", text: $checklistItems[index].text)
                                                            }
                                                        }
                                                        Spacer()
                                                        Button(action: {
                                                            removeChecklistItem(at: index)
                                                        }) {
                                                            Image(systemName: "minus.circle")
                                                                            .foregroundColor(.gray)
                                                                            .font(.title2)
                                                        }
                                                    }
                                                    .padding()
                                                    .background(Color(UIColor.systemGray6))
                                                    .cornerRadius(8)
                                                }
                                                .padding(.top, 10)
                                            }
                                            .padding(10)
                                        }
                                    }
                                )
                        }
                    }
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: { showTitleSheet = true }) {
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
        .onAppear {
            if let note = existingNote {
                title = note.title
                textContent = note.content
                selectedType = note.type
                checklistItems = note.checklistItems ?? []
                textAlignment = note.textAlignment?.textAlignment ?? .leading
            }
        }
    }

    private func removeChecklistItem(at index: Int) {
        checklistItems.remove(at: index)
    }
 
    private func addChecklistItem() {
        guard !newChecklistText.isEmpty else { return }
        let newItem = ChecklistItem(id: UUID(), text: newChecklistText, isChecked: false)
        checklistItems.append(newItem)
        newChecklistText = ""
    }

    private func saveNote() {
        if let note = existingNote {
            viewModel.updateNote(note: note,
                                 title: title,
                                 content: textContent,
                                 type: selectedType,
                                 drawingData: nil,
                                 checklistItems: checklistItems,
                                 fontSize: 0,
                                 textColor: textColor.toHex() ?? "#000000",
                                 isBold: false,
                                 isItalic: false,
                                 isUnderlined: false,
                                 textAlignment: TextAlignmentWrapper(textAlignment: textAlignment)
            )
        } else {
            let newNote = Note(
                id: UUID(),
                title: title,
                content: textContent,
                type: selectedType,
                checklistItems: checklistItems,
                drawingData: nil,
                fontSize: 0,
                textColor: textColor.toHex() ?? "#000000",
                isBold: false,
                isItalic: false,
                isUnderlined: false,
                textAlignment: TextAlignmentWrapper(textAlignment: textAlignment)
            )
            viewModel.addNote(note: newNote)
        }
    }

    
}

struct ChecklistItem: Identifiable, Codable {
    var id: UUID
    var text: String
    var isChecked: Bool
}



