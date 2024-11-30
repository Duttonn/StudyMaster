//
//  HelperFunctions.swift
//  StudyMaster
//
//  Created by DUTTON Natao on 30/11/2024.
//

import Foundation
import CoreData
import SwiftUI

func initializeRandomQuizzes(context: NSManagedObjectContext) {
    // Fetch existing quizzes
    let fetchRequest = NSFetchRequest<Quizz>(entityName: "Quizz")
        do {
            let existingQuizzes = try context.fetch(fetchRequest)
            if !existingQuizzes.isEmpty {
                print("Quizzes already exist in Core Data.")
                return // Exit if quizzes already exist
            }
        } catch {
            print("Failed to fetch quizzes: \(error.localizedDescription)")
            return
        }

    
    let sampleQuizzes = [
        ("Quelle est la transformée de Laplace de la réponse impulsionnelle d'un système sans conditions initiales ?",
         "$H(p) = \\frac{S(p)}{E(p)}$",
         [
             "$H(p) = \\frac{S(p)}{E(p)}$",
             "$H(p) = S(p) + E(p)$",
             "$H(p) = S(p) \\cdot E(p)$",
             "$H(p) = S(p) - E(p)$"
         ]),
        ("Quel est le critère pour qu'un système soit stable selon les pôles ?",
         "Les pôles doivent avoir une partie réelle négative",
         [
             "Les pôles doivent avoir une partie réelle négative",
             "Les pôles doivent être complexes",
             "Les pôles doivent être à partie réelle positive",
             "Les pôles doivent être imaginaires purs"
         ]),
        ("Que représente le diagramme de Bode ?",
         "La réponse fréquentielle d'un système",
         [
             "La réponse fréquentielle d'un système",
             "La stabilité d'un système",
             "La réponse impulsionnelle d'un système",
             "La phase et l'amplitude à zéro"
         ]),
        ("Dans un système causal, quelle est l'équation caractéristique typique ?",
         "$a_n \\cdot p^n + a_{n-1} \\cdot p^{n-1} + \\ldots + a_0 = 0$",
         [
             "$a_n \\cdot p^n + a_{n-1} \\cdot p^{n-1} + \\ldots + a_0 = 0$",
             "$p^n + p^{n-1} + \\ldots = 0$",
             "$a_n + a_{n-1} + \\ldots + a_0 = 0$",
             "$a_n \\cdot p + a_{n-1} = 0$"
         ]),
        ("Que signifie une décroissance exponentielle de la réponse d'un système ?",
         "Le système est stable",
         [
             "Le système est stable",
             "Le système est instable",
             "Le système est critique",
             "Le système oscille"
         ]),
        ("Quelle est la condition pour qu'un système ait une phase minimale ?",
         "Tous ses zéros doivent être à l'intérieur du cercle unité",
         [
             "Tous ses zéros doivent être à l'intérieur du cercle unité",
             "Tous ses pôles doivent être réels",
             "Tous ses pôles doivent être positifs",
             "Tous ses zéros doivent être réels"
         ]),
        ("Dans une boucle ouverte, comment est calculée la fonction de transfert ?",
         "$T(p) = G(p) \\cdot H(p)$",
         [
             "$T(p) = G(p) \\cdot H(p)$",
             "$T(p) = G(p) + H(p)$",
             "$T(p) = G(p) / H(p)$",
             "$T(p) = G(p) - H(p)$"
         ]),
        ("Quelle est l'expression mathématique pour une fonction de transfert en boucle fermée ?",
         "$H(p) = \\frac{G(p)}{1 + G(p)H(p)}$",
         [
             "$H(p) = \\frac{G(p)}{1 + G(p)H(p)}$",
             "$H(p) = G(p) \\cdot H(p)$",
             "$H(p) = G(p) - H(p)$",
             "$H(p) = G(p) + H(p)$"
         ]),
        ("Que signifie un pôle avec une partie réelle positive ?",
         "Le système est instable",
         [
             "Le système est instable",
             "Le système est stable",
             "Le système est critique",
             "Le système oscille"
         ]),
        ("Dans un système LTI, que relie la fonction de transfert $H(p)$ ?",
         "La sortie $S(p)$ à l'entrée $E(p)$",
         [
             "La sortie $S(p)$ à l'entrée $E(p)$",
             "La stabilité au gain",
             "La fréquence à la phase",
             "La réponse impulsionnelle au temps"
         ])
    ].shuffled() // Shuffle the questions here
    
    for (questionText, correctAnswer, options) in sampleQuizzes {
        let randomizedOptions = options.shuffled() // Shuffle the options
        let newQuiz = Quizz(context: context)
        newQuiz.questionText = questionText
        newQuiz.correctAnswer = correctAnswer
        newQuiz.options = randomizedOptions
    }
    
    do {
        try context.save()
        print("Random quizzes initialized and saved to Core Data.")
    } catch {
        print("Failed to save quizzes: \(error.localizedDescription)")
    }
}

