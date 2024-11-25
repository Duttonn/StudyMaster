import SwiftUI

struct ItemDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: NoteEntity

    @FocusState private var isContentFocused: Bool // To manage focus on the content editor
    @State private var editedName: String
    @State private var editedContent: String

    init(item: NoteEntity) {
        self.item = item
        _editedName = State(initialValue: item.name ?? "New Note")
        _editedContent = State(initialValue: item.content ?? "")
    }

    var body: some View {
        VStack {
            TextField("Note Title", text: $editedName, onCommit: {
                isContentFocused = true // Automatically focus on content after editing title
            })
            .font(.title)
            .fontWeight(.bold)
            .padding(10)
            .cornerRadius(8)
            .focused($isContentFocused, equals: false) // Ensure content can become focused
            .onChange(of: editedName) { _ in saveChanges() }

            Divider()
                .padding(.vertical)

            TextEditor(text: $editedContent)
                .font(.body)
                .padding(10)
                .cornerRadius(8)
                .focused($isContentFocused) // Enable content focus
                .onChange(of: editedContent) { _ in saveChanges() }

            Spacer()
        }
        .padding()
        .onAppear {
            if editedName == "New Note" {
                isContentFocused = true // Focus on content if this is a new note
            }
        }
        .onDisappear {
            handleAutomaticTitleUpdate() // Automatically update title when leaving the note
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Methods

    private func saveChanges() {
        withAnimation {
            item.name = editedName
            item.content = editedContent
            item.timestamp = Date() // Update last modified date

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error saving changes: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func handleAutomaticTitleUpdate() {
        if editedName == "New Note", !editedContent.isEmpty {
            // Trim content to remove leading/trailing spaces and newline characters
            let trimmedContent = editedContent.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Extract the first word, handling spaces and newline splits properly
            if let firstWord = trimmedContent.split(maxSplits: 1, omittingEmptySubsequences: true, whereSeparator: { $0.isWhitespace || $0.isNewline }).first {
                editedName = String(firstWord)
                saveChanges()
            }
        }
    }

}
