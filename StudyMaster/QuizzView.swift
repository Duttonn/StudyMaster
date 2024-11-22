import SwiftUI
import CoreData
import LaTeXSwiftUI

@objc(Quizz)
public class Quizz: NSManagedObject {
    @NSManaged public var questionText: String
    @NSManaged public var correctAnswer: String
    @NSManaged public var options: [String]?
}
struct QuizView: View {
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

    var score: Double {
        // Convert progress (0.0 to 1.0) to score (40 to 100)
        max(40, 40 + progress * 60)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Timer and Score Header
                headerView()
                
                // Main Content
                if !quizCompleted {
                    if let question = questions[safe: currentQuizIndex] {
                        VStack(spacing: 10) {
                            // Title and Answers
                            VStack(spacing: 10) {
                                // Title
                                ScrollView {
                                    LaTeX(question.questionText)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                .frame(height: 120) // Allocate space for the title

                                // Answer Options
                                VStack(spacing: 5) {
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
                            }
                            .frame(maxHeight: .infinity) // Distribute space evenly
                            .padding(.top, 10)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    VStack {
                        Text("Quiz Completed!")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        let meanScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)
                        Text("Mean Score: \(Int(meanScore))")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                        Button(action: replayQuizzes) {
                            Text("Replay Quiz")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
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
                .padding(.bottom, 20) // Add padding for safe area
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

    // Single Header View with Timer and Score
    private func headerView() -> some View {
        HStack {
            Spacer()
            VStack {
                // Timer Circle
                CircularProgressBar(progress: $progress)
                    .frame(width: 50, height: 50)
                Text("Score: \(Int(score))")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .zIndex(1) // Ensure it stays fixed
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



//
//func backgroundColor(for option: String, correctAnswer: String?) -> Color {
//    if option == correctAnswer && (hasAnsweredCorrectly) {
//        return Color.green
//    } else if wrongAttempts.contains(option) {
//        return Color.red
//    } else {
//        return Color.gray.opacity(0.3)
//    }
//}


func initializeRandomQuizzes(context: NSManagedObjectContext) {
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
         "$H(p) = G(p) \\cdot H(p)$",
         [
             "$H(p) = G(p) \\cdot H(p)$",
             "$H(p) = G(p) + H(p)$",
             "$H(p) = G(p) / H(p)$",
             "$H(p) = G(p) - H(p)$"
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
    ]
.shuffled() // Shuffle the questions here
    
    for (questionText, correctAnswer, options) in sampleQuizzes {
            var randomizedOptions = options // Start with the original options
            let correctAnswerIndex = Int.random(in: 0..<randomizedOptions.count) // Randomly pick a position for the correct answer
            
            // Remove the correct answer if it's already in the options
            randomizedOptions.removeAll { $0 == correctAnswer }
            
            // Insert the correct answer at the random index
            randomizedOptions.insert(correctAnswer, at: correctAnswerIndex)
            
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
