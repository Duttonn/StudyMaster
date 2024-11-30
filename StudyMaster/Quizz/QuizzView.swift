import SwiftUI
import CoreData
import LaTeXSwiftUI



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
    
    
    var subject: Subject

        init(subject: Subject) {
            self.subject = subject
            _questions = FetchRequest(
                entity: Quizz.entity(),
                sortDescriptors: [],
                predicate: NSPredicate(format: "subject == %@", subject)
            )
        }

    var meanScore: Double {
        scores.isEmpty ? 0.0 : scores.reduce(0.0, +) / Double(scores.count)
    }

    var score: Double {
        // Grading system: base score (40) + remaining time weighted for speed and penalties
        let baseScore = 40.0
        let timeBonus = progress * 60.0 // Remaining seconds as score
        let wrongPenalty = Double(wrongAttempts.count) * 5.0 // -5 points per incorrect attempt
        return max(baseScore, baseScore + timeBonus - wrongPenalty)
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
                        VStack {
                            Spacer() // Pushes the content to the bottom
                            
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
                            .padding(.bottom, 100) // Ensures spacing above bottom buttons
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
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
                // Removed time deduction for wrong answers
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
