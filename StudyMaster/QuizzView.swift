import SwiftUI
import CoreData
import LaTeXSwiftUI

@objc(Quizz)
public class Quizz: NSManagedObject {
    @NSManaged public var questionText: String
    @NSManaged public var correctAnswer: String
    @NSManaged public var options: [String]?
}

struct QuizzView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Quizz.entity(), sortDescriptors: [])
    var questions: FetchedResults<Quizz>
    
    @State private var currentQuizIndex: Int = 0
    @State private var selectedAnswer: String? = nil
    @State private var wrongAttempts: Set<String> = []
    @State private var progress: CGFloat = 1.0 // Starts full (1.0 = 60 seconds)
    @State private var scores: [Double] = []
    @State private var quizCompleted: Bool = false
    @State private var hasAnsweredCorrectly: Bool = false
    @State private var timer: Timer? = nil

    var meanScore: Double {
        scores.isEmpty ? 0.0 : scores.reduce(0.0, +) / Double(scores.count)
    }

    var score: Double {
        max(40, 40 + progress * 60) // Convert progress to score (40 to 100)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if quizCompleted {
                ReplayView(meanScore: meanScore, replayAction: replayQuizzes)
            } else {
                VStack(spacing: 0) {
                    if let question = questions[safe: currentQuizIndex] {
                        // Header with Timer and Question
                        headerView(question: question)

                        Spacer()
                        
                        // Answer Options
                        VStack(spacing: 10) {
                            if let options = question.options {
                                ForEach(options, id: \.self) { option in
                                    Button(action: {
                                        handleAnswerSelection(option, correctAnswer: question.correctAnswer)
                                    }) {
                                        LaTeX(option)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(backgroundColor(for: option, correctAnswer: question.correctAnswer))
                                            .foregroundColor(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .shadow(radius: 1)
                                    }
                                    .disabled(hasAnsweredCorrectly || progress <= 0)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    Spacer()
                }
                
                // Fixed Buttons at the Bottom
                if !quizCompleted {
                    HStack(spacing: 10) {
                        // Forfeit Button
                        Button(action: forfeit) {
                            Text("Forfeit")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                        
                        // Next Question Button
                        Button(action: loadNextQuestion) {
                            Text("Next Question")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(hasAnsweredCorrectly || progress <= 0 ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                        }
                        .disabled(!hasAnsweredCorrectly && progress > 0)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            initializeRandomQuizzes(context: viewContext)
            startNewQuestion()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func headerView(question: FetchedResults<Quizz>.Element) -> some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                VStack {
                    CircularProgressBar(progress: $progress)
                        .frame(width: 50, height: 50)
                    Text("Score: \(Int(score))")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            
            // Question Text
            LaTeX(question.questionText)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .frame(maxWidth: .infinity) // Ensure the background takes full width
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(10)
        }
        .padding(.top, 10)
        .padding(.horizontal)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    // MARK: - Methods

    func handleAnswerSelection(_ selectedOption: String, correctAnswer: String?) {
        selectedAnswer = selectedOption
        if selectedOption == correctAnswer {
            hasAnsweredCorrectly = true
            stopTimer()
        } else {
            if !wrongAttempts.contains(selectedOption) {
                wrongAttempts.insert(selectedOption)
                progress = max(0, progress - (10.0 / 60.0)) // Deduct 10 seconds as a fraction of progress
            }
        }
    }

    func forfeit() {
        progress = 0 // Set progress to 0 immediately
    }

    func loadNextQuestion() {
        if questions.indices.contains(currentQuizIndex) {
            scores.append(score)
            withAnimation {
                currentQuizIndex += 1
            }
        }
        if currentQuizIndex >= questions.count {
            quizCompleted = true
        } else {
            startNewQuestion()
        }
    }

    func startNewQuestion() {
        selectedAnswer = nil
        wrongAttempts = []
        hasAnsweredCorrectly = false
        progress = 1.0 // Reset progress to full (60 seconds)
        startTimer()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if progress > 0 {
                progress -= 1.0 / 60.0 // Decrement progress over 60 seconds
            } else {
                stopTimer()
                hasAnsweredCorrectly = true
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func replayQuizzes() {
        scores.removeAll()
        currentQuizIndex = 0
        quizCompleted = false
        startNewQuestion()
    }

    func backgroundColor(for option: String, correctAnswer: String?) -> Color {
        if option == correctAnswer && (hasAnsweredCorrectly) {
            return Color.green
        } else if wrongAttempts.contains(option) {
            return Color.red
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}


extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


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

