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
    var questions: FetchedResults<Quizz>
    
    @State private var selectedAnswer: String? = nil
    @State private var correctAnswer: String? = nil
    @State private var wrongAttempts: Int = 0
    @State private var score: Double = 0.0
    @State private var startTime: Date?
    @State private var scoreStartTime: Date?
    @State private var hasAnsweredCorrectly: Bool = false
    @State private var wrongAnswers: Set<String> = [] // Track wrong answers

    var body: some View {
        VStack {
            if let question = questions.first {
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
                        .disabled(hasAnsweredCorrectly) // Disable further selections after correct answer
                    }
                } else {
                    Text("No options available")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                // Display score after answering correctly
                if hasAnsweredCorrectly {
                    Text("Score: \(Int(score))")
                        .font(.headline)
                        .padding()
                }
                
                Button("Next Question") {
                    loadNextQuestion()
                }
                .padding()
                .disabled(!hasAnsweredCorrectly) // Enable only after correct answer is selected
            }
        }
        .onAppear {
            loadQuizDataIfNeeded()
            startNewQuestion()
        }
    }
    
    // MARK: - Methods
    
    func handleAnswerSelection(_ selectedOption: String, correctAnswer: String?) {
        selectedAnswer = selectedOption
        
        if selectedOption == correctAnswer {
            // Correct answer selected
            hasAnsweredCorrectly = true
            calculateScore()
        } else {
            // Wrong answer selected
            wrongAttempts += 1
            wrongAnswers.insert(selectedOption) // Track this as a wrong answer
        }
    }
    
    func calculateScore() {
        // If the user answers within the first 5 seconds (scoreStartTime is nil), give full score of 100
        if scoreStartTime == nil {
            score = 100 / Double(wrongAttempts + 1) // Adjust based on wrong attempts
            return
        }
        
        // Calculate time taken after the 5-second delay
        let timeTaken = Date().timeIntervalSince(scoreStartTime!)
        let baseScore = max(100 - timeTaken * 10, 10) // Base score decreases over time, minimum score of 10
        
        // Adjust score based on wrong attempts
        score = baseScore / Double(wrongAttempts + 1)
        
        // Round up to 100 if score is above 90 and no wrong attempts
        if score > 90 && wrongAttempts == 0 {
            score = 100
        }
    }
    
    func backgroundColor(for option: String, correctAnswer: String?) -> Color {
        if option == correctAnswer && hasAnsweredCorrectly {
            return Color.green
        } else if wrongAnswers.contains(option) {
            return Color.red
        } else {
            return Color.gray
        }
    }
    
    func startNewQuestion() {
        // Reset variables for a new question
        selectedAnswer = nil
        correctAnswer = nil
        wrongAttempts = 0
        score = 0.0
        hasAnsweredCorrectly = false
        wrongAnswers.removeAll() // Clear tracked wrong answers
        startTime = Date() // Track the initial time
        scoreStartTime = nil // Reset score start time to nil

        // Delay the scoring start time by 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Only set scoreStartTime if the user hasn't already answered correctly
            if !hasAnsweredCorrectly {
                scoreStartTime = Date()
            }
        }
    }
    
    func loadNextQuestion() {
        startNewQuestion()
        // Logic for loading the next question could be added here
    }
    
    func loadQuizDataIfNeeded() {
        if questions.isEmpty {
            let newQuestion = Quizz(context: viewContext)
            newQuestion.questionText = "What is the capital of France?"
            newQuestion.correctAnswer = "Paris"
            newQuestion.options = ["Berlin", "Madrid", "Paris", "Rome"]
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to save data: \(error.localizedDescription)")
            }
        }
    }
}


func createNewQuizz(questionText: String, correctAnswer: String, options: [String], context: NSManagedObjectContext) {
    let newQuiz = Quizz(context: context)
    newQuiz.questionText = questionText
    newQuiz.correctAnswer = correctAnswer
    newQuiz.options = options
    
    do {
        try context.save()
        print("New quiz created successfully.")
    } catch {
        print("Failed to save new quiz: \(error.localizedDescription)")
    }
}


