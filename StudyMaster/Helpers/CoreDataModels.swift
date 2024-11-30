//
//  CoreData.swift
//  StudyMaster
//
//  Created by DUTTON Natao on 30/11/2024.
//
import Foundation
import CoreData


@objc(Quizz)
public class Quizz: NSManagedObject {
    @NSManaged public var questionText: String
    @NSManaged public var correctAnswer: String
    @NSManaged public var options: [String]?
    @NSManaged public var subject: Subject? // Link to Subject
}


@objc(Subject)
public class Subject: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var quizzes: Set<Quizz>?
    @NSManaged public var notes: Set<NoteEntity>? // New relationship
}


@objc(NoteEntity)
public class NoteEntity: NSManagedObject, Identifiable {
    @NSManaged public var name: String?
    @NSManaged public var content: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var subject: Subject? // New relationship
    
    public var id: NSManagedObjectID {
            return objectID
        }
}
