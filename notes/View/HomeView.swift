import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingTypeSelection = false
    @State private var navigationPath: Note.NoteType? = nil
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List(filteredNotes) { note in
                        NavigationLink(destination: destinationView(for: note)) {
                            HStack {
                                Image(systemName: icon(for: note.type))
                                    .foregroundColor(.blue)
                                Text(note.title)
                                    .font(.headline)
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                shareNote(note)
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                    .searchable(text: $searchText)
                    .navigationTitle("")
                }
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
                                title: Text("Select type of note"),
                                buttons: [
                                    .default(Text("Text note")) {
                                        navigationPath = .text
                                    },
                                    .default(Text("Checklist")) {
                                        navigationPath = .checklist
                                    },
                                    .default(Text("Draw")) {
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
                    destination: AddNoteView(viewModel: viewModel),
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
                    destination: AddNoteDraw(viewModel: viewModel),
                    tag: .drawing,
                    selection: $navigationPath,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
    }

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

    private func shareNote(_ note: Note) {
        let sharedLink = "https://miapp.com/nota/\(note.id)"
        let activityController = UIActivityViewController(activityItems: [sharedLink], applicationActivities: nil)
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true, completion: nil)
        }
    }

    private var filteredNotes: [Note] {
        if searchText.isEmpty {
            return viewModel.notes
        } else {
            return viewModel.notes.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }

    @ViewBuilder
    private func destinationView(for note: Note) -> some View {
        switch note.type {
        case .text:
            AddNoteView(viewModel: viewModel, existingNote: note)
        case .checklist:
            AddNoteCheck(viewModel: viewModel, existingNote: note)
        case .drawing:
            AddNoteDraw(viewModel: viewModel, existingNote: note)
        default:
            EmptyView()
        }
    }
}
