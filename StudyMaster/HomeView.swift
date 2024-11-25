import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("📘 StudyMaster")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 60)

                // Button for QuizView
                NavigationLink(destination: QuizzView().environment(\.managedObjectContext, viewContext)) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
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
                        Image(systemName: "note.text")
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
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
