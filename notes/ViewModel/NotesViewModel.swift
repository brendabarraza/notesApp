git
import SwiftUI

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = [] // Array de notas

    init() {
        loadNotes()
    }

    func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "notes")
        }
    }

    func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "notes"),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
    }
    
    func deleteNote(note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes() // Guarda los cambios después de eliminar
    }

    func updateNote(note: Note, title: String, content: String, type: Note.NoteType, drawingData: Data?, fontSize: CGFloat, textColor: String, isBold: Bool, isItalic: Bool, isUnderlined: Bool, textAlignment: TextAlignmentWrapper?) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].title = title
            notes[index].content = content
            notes[index].type = type
            notes[index].drawingData = drawingData
            notes[index].fontSize = fontSize
            notes[index].textColor = textColor
            notes[index].isBold = isBold
            notes[index].isItalic = isItalic
            notes[index].isUnderlined = isUnderlined
            notes[index].textAlignment = textAlignment
            saveNotes() // Guarda los cambios después de actualizar
        }
    }



    func addNote(note: Note) {
        notes.append(note)
        saveNotes()
    }
}

