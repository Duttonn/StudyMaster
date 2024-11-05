//
//  StudyMasterApp.swift
//  StudyMaster
//
//  Created by DUTTON Natao on 23/10/2024.
//

import SwiftUI
import CoreData

@main
struct StudyMasterApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
            clearAllQuizzes(context: persistenceController.container.viewContext)
        }
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
//            StandardContentView()
//            MenuView()
            QuizView()
//            NoteView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    func clearAllQuizzes(context: NSManagedObjectContext) {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Quizz.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
                print("All quizzes cleared from Core Data.")
            } catch {
                print("Failed to clear quizzes: \(error.localizedDescription)")
            }
        }
    
}

