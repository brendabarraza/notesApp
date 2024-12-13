
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingTypeSelection = false
    @State private var navigationPath: Note.NoteType? = nil

    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Título y botones
                    HStack {
                        Text("  All your notes")
                            .font(.largeTitle)
                            .padding(.leading)
                        
                        Spacer()
                        
                        // Botón de lupa
                        Button(action: {
                            print("Buscar notas")
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                                .padding()
                        }
                        .padding(.trailing)

                        // Botón de tres puntos
                        Button(action: {
                            print("Mostrar opciones")
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20))
                                .padding()
                        }
                    }
                    .padding(.top)

                    // Lista de notas
                    List(viewModel.notes) { note in
                        NavigationLink(destination: AddNoteView(viewModel: viewModel, existingNote: note)) {
                            HStack {
                                Image(systemName: icon(for: note.type))
                                    .foregroundColor(.blue)
                                Text(note.title)
                                    .font(.headline)
                            }
                        }
                    }
                    .navigationTitle(" ")
                }

                // Botón flotante para añadir una nueva nota
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingTypeSelection = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.blue))
                                .shadow(radius: 10)
                        }
                        .padding()
                        .actionSheet(isPresented: $showingTypeSelection) {
                            ActionSheet(
                                title: Text("Selecciona el tipo de nota"),
                                buttons: [
                                    .default(Text("Nota de texto")) {
                                        navigationPath = .text
                                    },
                                    .default(Text("Checklist")) {
                                        navigationPath = .checklist
                                    },
                                    .default(Text("Dibujo")) {
                                        navigationPath = .drawing
                                    },
                                    .cancel()
                                ]
                            )
                        }
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: destinationView(),
                    tag: .text,
                    selection: $navigationPath,
                    label: { EmptyView() }
                )
                .hidden()
            )
            .background(
                NavigationLink(
                    destination: AddNoteCheck(viewModel: viewModel),
                    tag: .checklist,
                    selection: $navigationPath,
                    label: { EmptyView() }
                )
                .hidden()
            )
            .background(
                NavigationLink(
                    destination: AddNoteDibujo(viewModel: viewModel),
                    tag: .drawing,
                    selection: $navigationPath,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
    }

    // Función para determinar el icono según el tipo de nota
    private func icon(for type: Note.NoteType) -> String {
        switch type {
        case .text:
            return "doc.text"
        case .checklist:
            return "checklist"
        case .drawing:
            return "paintbrush"
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        switch navigationPath {
        case .text:
            AddNoteView(viewModel: viewModel, selectedType: .text)
        case .checklist:
            AddNoteCheck(viewModel: viewModel)
        case .drawing:
            AddNoteDibujo(viewModel: viewModel, selectedType: .drawing)
        default:
            EmptyView()
        }
    }
}












