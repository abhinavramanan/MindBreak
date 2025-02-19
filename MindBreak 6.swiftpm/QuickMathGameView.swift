import SwiftUI

struct QuickMathGameView: View {
    @State private var currentQuestion: MathQuestion?
    @State private var userAnswer: String = ""
    @State private var score: Int = 0
    @State private var questionCount: Int = 0
    @State private var gamePhase = GamePhase.question
    @State private var feedbackMessage = ""
    @State private var showingGameOver = false
    
    @AppStorage("universalScore") private var universalScore: Int = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let totalQuestions = 10
    
    enum GamePhase {
        case question
        case feedback
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#02a59c").ignoresSafeArea()
            
            VStack(spacing: 24) {
                QuickMathScorePanel(questionCount: questionCount, 
                           totalQuestions: totalQuestions, 
                           score: score)
                QuickMathGameArea(
                    gamePhase: gamePhase,
                    currentQuestion: currentQuestion,
                    userAnswer: $userAnswer,
                    feedbackMessage: feedbackMessage,
                    onSubmit: checkAnswer
                )
            }
            .padding(16)
        }
        .alert("Game Over!", isPresented: $showingGameOver) {
            Button("OK") {
                universalScore += score
                dismiss()
            }
        } message: {
            Text("Final Score: \(score)")
        }
        .onAppear(perform: startGame)
        .keyboardShortcut(.defaultAction)
        .keyboardShortcut(.escape)
    }
    
    private func startGame() {
        score = 0
        questionCount = 0
        feedbackMessage = ""
        generateQuestion()
    }
    
    private func generateQuestion() {
        guard questionCount < totalQuestions else {
            showingGameOver = true
            universalScore += score
            return
        }
        
        questionCount += 1
        let operationType = Int.random(in: 0...2)
        let firstNumber = Int.random(in: 1...10)
        let secondNumber = Int.random(in: 1...10)
        
        currentQuestion = MathQuestion(
            firstNumber: firstNumber,
            secondNumber: secondNumber,
            operationType: operationType
        )
        
        userAnswer = ""
        gamePhase = .question
    }
    
    private func checkAnswer() {
        guard let question = currentQuestion,
              let userValue = Int(userAnswer) else {
            feedbackMessage = "Please enter a valid number."
            return
        }
        
        gamePhase = .feedback
        
        if userValue == question.correctAnswer {
            score += 10
            feedbackMessage = "Correct!"
        } else {
            feedbackMessage = "Wrong! The answer is \(question.correctAnswer)."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            generateQuestion()
        }
    }
}

// MARK: - Supporting Views

struct QuickMathScorePanel: View {
    let questionCount: Int
    let totalQuestions: Int
    let score: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Quick Math")
                .font(.system(size: 32, weight: .bold))
            
            VStack(spacing: 8) {
                Label("\(questionCount) / \(totalQuestions)",
                      systemImage: "questionmark.circle.dashed")
                .font(.system(size: 24))
                
                Label("\(score)", systemImage: "trophy.circle")
                    .font(.system(size: 28, weight: .bold))
            }
        }
        .foregroundColor(Color(hex: "#013640"))
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(hex: "#bcebf2"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct QuickMathGameArea: View {
    let gamePhase: QuickMathGameView.GamePhase
    let currentQuestion: MathQuestion?
    @Binding var userAnswer: String
    let feedbackMessage: String
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            if let question = currentQuestion {
                switch gamePhase {
                case .question:
                    QuestionView(
                        question: question,
                        userAnswer: $userAnswer,
                        onSubmit: onSubmit
                    )
                    .transition(.scale.combined(with: .opacity))
                    
                case .feedback:
                    QuickMathFeedbackView(
                        message: feedbackMessage,
                        isSuccess: Int(userAnswer) == question.correctAnswer
                    )
                    .transition(.scale)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(Color(hex: "#bcebf2").opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut, value: gamePhase)
    }
}

struct QuestionView: View {
    let question: MathQuestion
    @Binding var userAnswer: String
    let onSubmit: () -> Void
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Text("\(question.firstNumber) \(question.operationSymbol) \(question.secondNumber) = ?")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(Color(hex: "#013640"))
            
            TextField("Enter answer", text: $userAnswer)
                .focused($isInputFocused)
                .keyboardType(.decimalPad)
                .foregroundColor(Color(hex: "#02fcee"))
                .font(.system(size: 48, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(24)
                .background(Color(hex: "#39484b"))
                .cornerRadius(16)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button("-") {
                            if userAnswer.isEmpty {
                                userAnswer = "-"
                            } else if userAnswer.first == "-" {
                                userAnswer.removeFirst()
                            } else {
                                userAnswer = "-" + userAnswer
                            }
                        }
                        Spacer()
                    }
                }
            
            Button(action: onSubmit) {
                Text("Submit")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#013640"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#02fcee"))
                    .cornerRadius(16)
            }
            .keyboardShortcut(.defaultAction)
        }
        .onAppear {
            isInputFocused = true
        }
    }
}

struct QuickMathFeedbackView: View {
    let message: String
    let isSuccess: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(
                    isSuccess ? Color(hex: "#02fcee") : Color(hex: "#e17366")
                )
            
            Text(message)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(Color(hex: "#013640"))
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(Color(hex: "#bcebf2"))
        .cornerRadius(16)
    }
}

// MARK: - Model
struct MathQuestion {
    let firstNumber: Int
    let secondNumber: Int
    let operationType: Int
    
    var operationSymbol: String {
        switch operationType {
        case 0:  return "+"
        case 1:  return "-"
        default: return "×"
        }
    }
    
    var correctAnswer: Int {
        switch operationType {
        case 0:  return firstNumber + secondNumber
        case 1:  return firstNumber - secondNumber
        default: return firstNumber * secondNumber
        }
    }
}
