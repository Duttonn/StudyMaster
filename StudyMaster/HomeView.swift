import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \NoteEntity.timestamp, ascending: true)],
            animation: .default)
        private var items: FetchedResults<NoteEntity>

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                HStack {
                    Image(systemName: "graduationcap.fill")
                        .font(.largeTitle)
                        .padding(.top, 60)
                    
                    Text("StudyMaster")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 60)
                }
                
                // Button for QuizView
                NavigationLink(destination: QuizzView().environment(\.managedObjectContext, viewContext)) {
                    HStack {
                        Image(systemName: "list.number")
                            .font(.title2)
                        Text("Start Quiz")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 3)
                    .padding(.horizontal, 20)
                }

                // Button for NoteView
                NavigationLink(destination: NoteView().environment(\.managedObjectContext, viewContext)) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                        Text("View Notes")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: Color.green.opacity(0.4), radius: 5, x: 0, y: 3)
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
            .padding(.top)
//            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
