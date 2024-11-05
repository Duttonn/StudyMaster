import SwiftUI
import CoreData

@objc(Quizz)
public class Quizz: NSManagedObject {
    @NSManaged public var questionText: String
    @NSManaged public var correctAnswer: String
    @NSManaged public var options: [String]?
}

struct QuizView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Quizz.entity(), sortDescriptors: [])
    var questions: FetchedResults<Quizz> // Use FetchedResults to load from Core Data
    
    @State private var currentQuizIndex: Int = 0
    @State private var selectedAnswer: String? = nil
    @State private var wrongAttempts: Set<String> = [] // Track unique wrong answers
    @State private var score: Double = 0.0
    @State private var startTime: Date?
    @State private var scoreStartTime: Date?
    @State private var hasAnsweredCorrectly: Bool = false
    @State private var wrongAnswers: Set<String> = [] // Track wrong answers for UI
    @State private var timeRemaining: Int = 15 // Timer in seconds
    @State private var timer: Timer? = nil // Reference to the timer
    @State private var completedQuizzes: [Quizz] = [] // Track completed quizzes for replay

    var body: some View {
        VStack {
            if !questions.isEmpty, questions.indices.contains(currentQuizIndex) {
                let question = questions[currentQuizIndex]
                
                Text("Temps restant: \(timeRemaining) sec")
                    .font(.headline)
                    .foregroundColor(timeRemaining > 0 ? .primary : .red)
                    .padding()
                
                Text(question.questionText ?? "No question available")
                    .font(.title)
                    .padding()
                
                if let options = question.options {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            handleAnswerSelection(option, correctAnswer: question.correctAnswer)
                        }) {
                            Text(option)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(backgroundColor(for: option, correctAnswer: question.correctAnswer))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        .disabled(hasAnsweredCorrectly || timeRemaining <= 0) // Disable if answered or time is up
                    }
                } else {
                    Text("No options available")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                if hasAnsweredCorrectly || timeRemaining <= 0 {
                    Text("Score: \(Int(score))")
                        .font(.headline)
                        .padding()
                }
                
                Button("Next Question") {
                    loadNextQuestion()
                }
                .padding()
                .disabled(!hasAnsweredCorrectly && timeRemaining > 0)
            } else {
                Text("No more quizzes available.")
                    .font(.title)
                    .padding()
                
                Button("Replay Quizzes") {
                    replayQuizzes()
                }
                .padding()
            }
        }
        .onAppear {
            loadQuizDataIfNeeded()
            startNewQuestion()
        }
        .onDisappear {
            timer?.invalidate() // Stop the timer when view disappears
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
            return Color.gray
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
        timeRemaining = 15 // Reset timer for each question
        startTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !hasAnsweredCorrectly {
                scoreStartTime = Date()
            }
        }
    }
    
    func loadNextQuestion() {
        if !questions.isEmpty, questions.indices.contains(currentQuizIndex) {
            completedQuizzes.append(questions[currentQuizIndex]) // Track completed quiz
            currentQuizIndex += 1
        }
        
        if currentQuizIndex >= questions.count {
            currentQuizIndex = 0
        }
        
        startNewQuestion()
    }
    
    func startTimer() {
        timer?.invalidate() // Stop any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                score = 0 // Set score to 0 if time is up
                hasAnsweredCorrectly = true // Mark question as answered
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func loadQuizDataIfNeeded() {
        // Create a fetch request specifically for Quizz entities
        let request = NSFetchRequest<Quizz>(entityName: "Quizz")
        request.predicate = NSPredicate(format: "questionText == %@", "What is the capital of France?")
        
        do {
            let existingQuizzes = try viewContext.fetch(request)
            if existingQuizzes.isEmpty {
                // If the quiz does not exist, add it
                let newQuestion = Quizz(context: viewContext)
                newQuestion.questionText = "What is the capital of France?"
                newQuestion.correctAnswer = "Paris"
                newQuestion.options = ["Berlin", "Madrid", "Paris", "Rome"]
                
                try viewContext.save()
                print("Basic quiz added to Core Data.")
            }
        } catch {
            print("Failed to check or save the basic quiz: \(error.localizedDescription)")
        }
    }

    func replayQuizzes() {
        completedQuizzes.forEach { quiz in
            let replayedQuiz = Quizz(context: viewContext)
            replayedQuiz.questionText = quiz.questionText
            replayedQuiz.correctAnswer = quiz.correctAnswer
            replayedQuiz.options = quiz.options
        }
        
        completedQuizzes.removeAll() // Clear the completed quizzes list
        currentQuizIndex = 0 // Reset to the beginning
        startNewQuestion()
        
        do {
            try viewContext.save()
            print("All quizzes have been replayed.")
        } catch {
            print("Failed to save replayed quizzes: \(error.localizedDescription)")
        }
    }
}
