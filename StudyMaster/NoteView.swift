import SwiftUI
import CoreData

struct NoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NoteEntity.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<NoteEntity>
    
    // State variables for the item creation alert
    @State private var presentAlert = false
    @State private var itemName: String = ""
    @State private var itemContent: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // Filter items that have a valid name
                    ForEach(items.filter { !($0.name?.isEmpty ?? true) }) { item in
                        NavigationLink {
                            VStack(alignment: .leading) {
                                Text("Name: \(item.name ?? "Unnamed")")
                                    .font(.headline)
                                Text("Content: \(item.content ?? "No content")")
                                    .font(.subheadline)
//                                Text("Created at \(item.timestamp!, formatter: itemFormatter)")
//                                    .font(.footnote)
                            }
                        } label: {
                            Text(item.name ?? "Unnamed Item")
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: {
                            presentAlert = true
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                .alert("Create New Item", isPresented: $presentAlert, actions: {
                    TextField("Item Name", text: $itemName)
                    TextField("Item Content", text: $itemContent)
                    
                    Button("Save", action: saveItem)
                    Button("Cancel", role: .cancel, action: clearFields)
                }, message: {
                    Text("Enter a name and content for the new item.")
                })
            }
            Text("Select an item")
        }
    }

    // Function to save the new item to Core Data
    private func saveItem() {
        guard !itemName.isEmpty else {
            print("Item name cannot be empty!")
            return
        }
        
        withAnimation {
            let newItem = NoteEntity(context: viewContext)
            newItem.name = itemName
            newItem.content = itemContent
            newItem.timestamp = Date()

            do {
                try viewContext.save()
                print("Item saved successfully! Name: \(newItem.name ?? "No Name"), Content: \(newItem.content ?? "No Content")")
                clearFields()
            } catch {
                // Log the error details for debugging
                let nsError = error as NSError
                print("Error saving item: \(nsError), UserInfo: \(nsError.userInfo)")
            }
        }
    }



    // Function to clear the input fields
    private func clearFields() {
        itemName = ""
        itemContent = ""
    }

    // Function to delete items
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    NoteView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
