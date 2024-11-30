//
//  AddSubjectSheet.swift
//  StudyMaster
//
//  Created by DUTTON Natao on 30/11/2024.
//

import SwiftUI

struct AddSubjectSheet: View {
    @Binding var showAddSubjectSheet: Bool
    @Environment(\.managedObjectContext) private var viewContext

    @State private var newSubjectName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter subject name", text: $newSubjectName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: createSubject) {
                    Text("Add Subject")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(newSubjectName.isEmpty)
                .padding()

                Spacer()
            }
            .navigationTitle("New Subject")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddSubjectSheet = false
                    }
                }
            }
        }
    }

    private func createSubject() {
        guard !newSubjectName.isEmpty else { return }

        let newSubject = Subject(context: viewContext)
        newSubject.name = newSubjectName

        do {
            try viewContext.save()
            showAddSubjectSheet = false // Dismiss the sheet
        } catch {
            print("Failed to save subject: \(error.localizedDescription)")
        }
    }
}
