//
//  StudyMasterApp.swift
//  StudyMaster
//
//  Created by DUTTON Natao on 23/10/2024.
//

import SwiftUI

@main
struct StudyMasterApp: App {
    let persistenceController = PersistenceController.shared
    
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
}

