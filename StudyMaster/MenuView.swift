import SwiftUI

struct MenuView: View {
    // Accessing the Core Data context from the environment
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Button to navigate to StandardContentView
                NavigationLink(destination: NoteView()
                                .environment(\.managedObjectContext, viewContext)) {
                    Text("Open Notes")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .navigationTitle("Menu")
            .padding()
        }
    }
}

#Preview {
    MenuView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
