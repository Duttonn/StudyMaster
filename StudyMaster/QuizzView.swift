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

    init() {
        let viewContext = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<Quizz>(entityName: "Quizz")
        
        do {
            let existingQuizzes = try viewContext.fetch(request)
            if existingQuizzes.isEmpty {
            }
        } catch {
            print("Failed to check or save quizzes: \(error.localizedDescription)")
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                if !quizCompleted, !questions.isEmpty, questions.indices.contains(currentQuizIndex) {
                    let question = questions[currentQuizIndex]
                    
                    CircularProgressBar(progress: $progress)
                        .frame(width: 60, height: 60)
                        .padding(.top)
                    
                    Text(question.questionText ?? "No question available")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(width: geometry.size.width * 0.9)
                    
                    if let options = question.options {
                        VStack(spacing: 10) {
                            ForEach(options, id: \.self) { option in
                                Button(action: {
                                    handleAnswerSelection(option, correctAnswer: question.correctAnswer)
                                }) {
                                    Text(option)
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

//struct CircularProgressBar: View {
//    @Binding var progress: CGFloat
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .stroke(lineWidth: 10.0)
//                .opacity(0.3)
//                .foregroundColor(.blue)
//            
//            Circle()
//                .trim(from: 0.0, to: progress)
//                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
//                .foregroundColor(.blue)
//                .rotationEffect(Angle(degrees: 270.0))
//            
//            Text("\(Int(progress * 15))")
//                .font(.headline)
//                .bold()
//        }
//    }
//}

func initializeRandomQuizzes(context: NSManagedObjectContext) {
    let sampleQuizzes = [
        ("What is the capital of Germany?", "Berlin", ["Berlin", "Munich", "Frankfurt", "Hamburg"]),
        ("What is 2 + 2?", "4", ["3", "4", "5", "6"]),
        ("Which planet is known as the Red Planet?", "Mars", ["Earth", "Mars", "Jupiter", "Saturn"]),
        ("What is the boiling point of water?", "100°C", ["90°C", "100°C", "110°C", "120°C"]),
        ("Who wrote 'To be, or not to be'?", "William Shakespeare", ["J.K. Rowling", "Ernest Hemingway", "William Shakespeare", "Charles Dickens"]),
        ("What is the square root of 16?", "4", ["2", "3", "4", "5"]),
        ("What is the chemical symbol for water?", "H2O", ["H2O", "CO2", "O2", "NaCl"]),
        ("What color do you get when you mix red and blue?", "Purple", ["Green", "Yellow", "Purple", "Orange"]),
        ("Which animal is known as the king of the jungle?", "Lion", ["Elephant", "Tiger", "Lion", "Giraffe"]),
        ("What is the largest planet in our solar system?", "Jupiter", ["Earth", "Mars", "Jupiter", "Saturn"])
    ]
    
    let randomQuizzes = sampleQuizzes.shuffled()
    
    for (questionText, correctAnswer, options) in randomQuizzes {
        let newQuiz = Quizz(context: context)
        newQuiz.questionText = questionText
        newQuiz.correctAnswer = correctAnswer
        newQuiz.options = options
    }
    
    do {
        try context.save()
        print("Random quizzes initialized and saved to Core Data.")
    } catch {
        print("Failed to save quizzes: \(error.localizedDescription)")
    }
}
