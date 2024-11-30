import SwiftUI
import CoreData


struct NoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var items: FetchedResults<NoteEntity>

    var subject: Subject // The subject associated with this view

    @State private var selectedNote: NoteEntity? = nil // Track selected note for navigation

    // Initialize fetch request with a predicate for the subject
    init(subject: Subject) {
        self.subject = subject
        _items = FetchRequest(
            entity: NoteEntity.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \NoteEntity.timestamp, ascending: true)],
            predicate: NSPredicate(format: "subject == %@", subject),
            animation: .default
        )
    }

    var body: some View {
        VStack {
            // List of Notes
            List {
                ForEach(items.filter { !($0.name?.isEmpty ?? true) }) { item in
                    NavigationLink(destination: ItemDetailView(item: item), tag: item, selection: $selectedNote) {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unnamed")
                                .font(.headline)
                            Text(item.content ?? "No content")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Last modified: \(formattedDate(item.timestamp))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: createAndSelectNote) {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
        }
        .navigationTitle("Notes for \(subject.name)")
    }

    // MARK: - Methods

    private func createAndSelectNote() {
        withAnimation {
            let newNote = NoteEntity(context: viewContext)
            newNote.name = "New Note"
            newNote.content = ""
            newNote.timestamp = Date()
            newNote.subject = subject // Link the note to the current subject

            do {
                try viewContext.save()
                selectedNote = newNote // Automatically select the newly created note
            } catch {
                let nsError = error as NSError
                print("Error creating new note: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting item: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
