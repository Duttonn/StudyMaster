//
//  SubjectDetailView.swift
//  StudyMaster
//
//  Created by DUTTON Natao on 30/11/2024.
//

import SwiftUI
import CoreData


struct SubjectDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var subject: Subject

    var body: some View {
        VStack {
            

            // Navigation to Quizzes
            NavigationLink(destination: QuizzView(subject: subject).environment(\.managedObjectContext, viewContext)) {
                Text("Start Quizzes")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding()

            // Navigation to Notes
            NavigationLink(destination: NoteView(subject: subject).environment(\.managedObjectContext, viewContext)) {
//            NavigationLink(destination: NoteView(subject: subject).environment(\.managedObjectContext, viewContext)) {
                Text("View Notes")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding()

            Spacer()
        }
        .navigationTitle(subject.name)
    }
}

