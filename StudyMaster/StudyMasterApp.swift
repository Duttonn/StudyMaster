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
    let APIKey = "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"
    init() {
        clearAllQuizzes(context: persistenceController.container.viewContext)
    }
    
    var body: some Scene {
        WindowGroup {
            SubjectsView()
//            QuizzView()
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
