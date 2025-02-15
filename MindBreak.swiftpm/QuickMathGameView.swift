
import SwiftUI

struct QuickMathGameView: View {
    @State private var currentQuestion: MathQuestion?
    @State private var userAnswer: String = ""
    @State private var score: Int = 0
    @State private var questionCount: Int = 0
    @State private var gameActive: Bool = false
    @State private var feedback: String = ""
    
    private let totalQuestions = 10
    
    var body: some View {
        ZStack { 
            VStack(spacing: 24) {
                HStack {
                    Text("Quick Maths")
                        .font(.largeTitle)
                        .foregroundColor(Color(hex: "#013640"))
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                if gameActive {
                    HStack {
                        Label("\(questionCount) / \(totalQuestions)", systemImage: "questionmark.circle.dashed")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#013640"))
                            .padding(.bottom, 8)
                        
                        Spacer()
                        
                        Label("\(score)", systemImage: "trophy.circle")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#013640"))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                if gameActive {
                    
                    
                    if let question = currentQuestion {
                        Text("\(question.firstNumber) \(question.operationSymbol) \(question.secondNumber) = ?")
                            .font(.title)
                            .padding(.bottom, 16)
                            .foregroundColor(Color(hex: "#013640"))
                        
                        TextField("Enter answer", text: $userAnswer)
                            .keyboardType(.decimalPad)
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
                            .padding()
                            .foregroundColor(Color(hex: "#02fcee"))
                            .background(Color(hex: "#39484b"))
                            .cornerRadius(20)
                            .frame(width: 150)
                            .multilineTextAlignment(.center)
                        
                        Button(action: checkAnswer) {
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#013640"))
                                .frame(width: 50, height: 50)
                                .bold()
                                .background(Color(hex: "#02fcee"))
                                .cornerRadius(20)
                        }
                        
                        Text(feedback)
                            .padding()
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color(hex: "#013640"))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                } else {
                    Button(action: startGame) {
                        Text("Start Game")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#013640"))
                            .padding()
                            .background(Color(hex: "#02fcee"))
                            .bold()
                            .cornerRadius(20)
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#02a59c"))
        }
    }
    
    private func startGame() {
        score = 0
        questionCount = 0
        gameActive = true
        generateQuestion()
    }
    
    private func generateQuestion() {
        guard questionCount < totalQuestions else {
            gameActive = false
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            generateQuestion()
        }
    }
}

struct MathQuestion {
    let firstNumber: Int
    let secondNumber: Int
    let operationType: Int
    
    var operationSymbol: String {
        switch operationType {
        case 0: return "+"
        case 1: return "-"
        default: return "×"
        }
    }
    
    var correctAnswer: Int {
        switch operationType {
        case 0: return firstNumber + secondNumber
        case 1: return firstNumber - secondNumber
        default: return firstNumber * secondNumber
        }
    }
}


#Preview {
    QuickMathGameView()
}
