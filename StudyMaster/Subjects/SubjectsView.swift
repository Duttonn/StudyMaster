//
//  SubjectsView.swift
//  StudyMaster
//
//  Created by DUTTON Natao on 30/11/2024.
//

import SwiftUI
import CoreData

struct SubjectsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Subject.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
    var subjects: FetchedResults<Subject>

    @State private var newSubjectName: String = ""
    @State private var showAddSubjectSheet: Bool = false // To display the input UI for a new subject

    var body: some View {
        NavigationView {
            VStack {
                // List of Subjects
                List {
                    ForEach(subjects, id: \.self) { subject in
                        NavigationLink(destination: SubjectDetailView(subject: subject).environment(\.managedObjectContext, viewContext)) {
                            Text(subject.name)
                                .font(.headline)
                        }
                    }
                    .onDelete(perform: deleteSubject)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Subjects")
            .toolbar {
                // Add Subject Toolbar Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddSubjectSheet = true }) {
                        Label("Add Subject", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSubjectSheet) {
                AddSubjectSheet(showAddSubjectSheet: $showAddSubjectSheet).environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteSubject(at offsets: IndexSet) {
        for index in offsets {
            let subject = subjects[index]
            viewContext.delete(subject)
        }

        do {
            try viewContext.save()
        } catch {
            print("Failed to delete subject: \(error.localizedDescription)")
        }
    }
}


