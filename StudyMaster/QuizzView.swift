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
    @State private var score: Double = 0.0
    @State private var scores: [Double] = []
    @State private var startTime: Date?
    @State private var scoreStartTime: Date?
    @State private var hasAnsweredCorrectly: Bool = false
    @State private var wrongAnswers: Set<String> = []
    @State private var timeRemaining: Int = 15
    @State private var timer: Timer? = nil
    @State private var completedQuizzes: [Quizz] = []
    @State private var quizCompleted: Bool = false
    @State private var progress: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                if !quizCompleted, !questions.isEmpty, questions.indices.contains(currentQuizIndex) {
                    let question = questions[currentQuizIndex]
                    
                    CircularProgressBar(progress: $progress)
                        .frame(width: 40, height: 40)
                        .padding(.top)
                    
                    LaTeX(question.questionText ?? "No question available")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .frame(width: geometry.size.width * 0.9)
                    
                    if let options = question.options {
                        VStack(spacing: 10) {
                            ForEach(options, id: \.self) { option in
                                Button(action: {
                                    handleAnswerSelection(option, correctAnswer: question.correctAnswer)
                                }) {
                                    LaTeX(option)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(backgroundColor(for: option, correctAnswer: question.correctAnswer))
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(radius: selectedAnswer == option ? 3 : 0)
                                }
                                .disabled(hasAnsweredCorrectly || timeRemaining <= 0)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Text("No options available")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                    if hasAnsweredCorrectly || timeRemaining <= 0 {
                        Text("Score: \(Int(score))")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                    }
                    
                    Button(action: loadNextQuestion) {
                        Text("Next Question")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasAnsweredCorrectly || timeRemaining <= 0 ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                    .disabled(!hasAnsweredCorrectly && timeRemaining > 0)
                } else if quizCompleted {
                    let meanScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)
                    
                    Text("All quizzes completed!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                    
                    Text("Mean Score: \(Int(meanScore))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding()
                    
                    Button(action: replayQuizzes) {
                        Text("Replay Quizzes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                }
            }
            .frame(width: geometry.size.width)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .onAppear {
            initializeRandomQuizzes(context: viewContext)
            startNewQuestion()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Methods

    func handleAnswerSelection(_ selectedOption: String, correctAnswer: String?) {
        selectedAnswer = selectedOption
        
        if selectedOption == correctAnswer {
            hasAnsweredCorrectly = true
            calculateScore()
            stopTimer()
        } else {
            if !wrongAttempts.contains(selectedOption) {
                wrongAttempts.insert(selectedOption)
                wrongAnswers.insert(selectedOption)
            }
        }
    }
    
    func calculateScore() {
        if timeRemaining <= 0 {
            score = 0
            return
        }
        
        if scoreStartTime == nil {
            score = 100 / Double(wrongAttempts.count + 1)
            return
        }
        
        let timeTaken = Date().timeIntervalSince(scoreStartTime!)
        let baseScore = max(100 - timeTaken * 10, 10)
        
        score = baseScore / Double(wrongAttempts.count + 1)
        
        if score > 90 && wrongAttempts.isEmpty {
            score = 100
        }
    }
    
    func backgroundColor(for option: String, correctAnswer: String?) -> Color {
        if option == correctAnswer && (hasAnsweredCorrectly || timeRemaining <= 0) {
            return Color.green
        } else if wrongAnswers.contains(option) {
            return Color.red
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    func startNewQuestion() {
        selectedAnswer = nil
        wrongAttempts = []
        wrongAnswers = []
        score = 0.0
        hasAnsweredCorrectly = false
        startTime = Date()
        scoreStartTime = nil
        timeRemaining = 15
        progress = 1.0
        startTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !hasAnsweredCorrectly {
                scoreStartTime = Date()
            }
        }
    }
    
    func loadNextQuestion() {
        if questions.indices.contains(currentQuizIndex) {
            completedQuizzes.append(questions[currentQuizIndex])
            scores.append(score)
            currentQuizIndex += 1
        }
        
        if currentQuizIndex >= questions.count {
            quizCompleted = true
        } else {
            startNewQuestion()
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                progress = CGFloat(timeRemaining) / 15.0
            } else {
                stopTimer()
                score = 0
                hasAnsweredCorrectly = true
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func replayQuizzes() {
        completedQuizzes.forEach { quiz in
            let replayedQuiz = Quizz(context: viewContext)
            replayedQuiz.questionText = quiz.questionText
            replayedQuiz.correctAnswer = quiz.correctAnswer
            replayedQuiz.options = quiz.options
        }
        
        completedQuizzes.removeAll()
        scores.removeAll()
        currentQuizIndex = 0
        quizCompleted = false
        startNewQuestion()
        
        do {
            try viewContext.save()
            print("All quizzes have been replayed.")
        } catch {
            print("Failed to save replayed quizzes: \(error.localizedDescription)")
        }
    }
}

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
