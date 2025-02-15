import SwiftUI

struct QuickMathGameView: View {
    @State private var currentQuestion: MathQuestion?
    @State private var userAnswer: String = ""
    @State private var score: Int = 0
    @State private var questionCount: Int = 0
    @State private var gameActive: Bool = false
    @State private var feedback: String = ""
    
    // Reference the universal score
    @AppStorage("universalScore") private var universalScore: Int = 0
    
    private let totalQuestions = 10
    
    var body: some View {
        VStack(spacing: 24) {
            // Header Row
            HStack {
                Text("Quick Maths")
                    .font(.largeTitle)
                    .foregroundColor(Color(hex: "#013640"))
                    .bold()
                
                Spacer()
            }
            .padding(.top)
            
            // Game Info Row
            if gameActive {
                HStack {
                    Label("\(questionCount) / \(totalQuestions)",
                          systemImage: "questionmark.circle.dashed")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#013640"))
                    
                    Spacer()
                    
                    Label("\(score)", systemImage: "trophy.circle")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#013640"))
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Main Game Layout
            if gameActive {
                if let question = currentQuestion {
                    // Present question
                    Text("\(question.firstNumber) \(question.operationSymbol) \(question.secondNumber) = ?")
                        .font(.title)
                        .foregroundColor(Color(hex: "#013640"))
                        .padding(.bottom)
                    
                    // Answer input field
                    TextField("Enter answer", text: $userAnswer)
                        .keyboardType(.decimalPad)
                        .padding()
                        .foregroundColor(Color(hex: "#02fcee"))
                        .background(Color(hex: "#39484b"))
                        .cornerRadius(12)
                        .frame(width: 150)
                        .multilineTextAlignment(.center)
                    // Optional minus button in toolbar
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
                    
                    // Submit button
                    Button(action: checkAnswer) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(Color(hex: "#02fcee"))
                            .foregroundColor(Color(hex: "#013640"))
                            .cornerRadius(12)
                    }
                    .padding(.top)
                    
                    // Feedback message
                    Text(feedback)
                        .padding(.top)
                        .foregroundColor(Color(hex: "#013640"))
                        .font(.headline)
                }
            } else {
                // Start or Replay button
                Button(action: startGame) {
                    Text("Start Game")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#013640"))
                        .padding()
                        .background(Color(hex: "#02fcee"))
                        .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#02a59c"))
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        score = 0
        questionCount = 0
        feedback = ""
        gameActive = true
        generateQuestion()
    }
    
    private func generateQuestion() {
        // Check if we've reached the total question limit
        guard questionCount < totalQuestions else {
            // End the game if all questions are done
            gameActive = false
            // Update universal score with final points from this game
            universalScore += score
            return
        }
        
        questionCount += 1
        let operationType = Int.random(in: 0...2) // 0 for +, 1 for -, 2 for ×
        let firstNumber = Int.random(in: 1...10)
        let secondNumber = Int.random(in: 1...10)
        
        currentQuestion = MathQuestion(
            firstNumber: firstNumber,
            secondNumber: secondNumber,
            operationType: operationType
        )
        
        userAnswer = ""
        feedback = ""
    }
    
    private func checkAnswer() {
        guard let question = currentQuestion,
              let userValue = Int(userAnswer) else {
            feedback = "Please enter a valid number."
            return
        }
        
        if userValue == question.correctAnswer {
            score += 10
            feedback = "Correct!"
        } else {
            feedback = "Wrong! The answer is \(question.correctAnswer)."
        }
        
        // Delay briefly, then move on
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            generateQuestion()
        }
    }
}

// MARK: - MathQuestion Model
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
