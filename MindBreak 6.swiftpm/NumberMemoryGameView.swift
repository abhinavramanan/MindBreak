import SwiftUI

struct NumberMemoryGameView: View {
    @State private var numbers: [Int] = []
    @State private var userInput: [Int] = []
    @State private var gamePhase = GamePhase.memorize
    @State private var level = 1
    @State private var score = 0
    @State private var feedbackMessage = ""
    @State private var showingGameOver = false
    
    @AppStorage("universalScore") private var universalScore: Int = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    enum GamePhase {
        case memorize
        case recall
        case feedback
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#02a59c").ignoresSafeArea()
            
            VStack(spacing: 24) {
                NumberMemoryScorePanel(level: level, score: score)
                NumberMemoryGameArea(
                    gamePhase: gamePhase,
                    numbers: numbers,
                    userInput: $userInput,
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
        .onAppear(perform: startNewRound)
        // Fixed keyboard shortcuts
        .keyboardShortcut(.defaultAction)
        .keyboardShortcut(.escape)
    }
    
    private func startNewRound() {
        numbers = generateNumbers(count: level + 2)
        userInput = []
        gamePhase = .memorize
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            gamePhase = .recall
        }
    }
    
    private func generateNumbers(count: Int) -> [Int] {
        (0..<count).map { _ in Int.random(in: 0...9) }
    }
    
    private func checkAnswer() {
        gamePhase = .feedback
        if userInput == numbers {
            feedbackMessage = "Correct! Great job!"
            score += level * 100
            level += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                startNewRound()
            }
        } else {
            feedbackMessage = "Incorrect!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showingGameOver = true
            }
        }
    }
}

struct NumberMemoryScorePanel: View {
    let level: Int
    let score: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Number Memory")
                .font(.system(size: 32, weight: .bold))
            
            VStack(spacing: 8) {
                Text("Level \(level)")
                    .font(.system(size: 24))
                Text("Score: \(score)")
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

struct NumberMemoryGameArea: View {
    let gamePhase: NumberMemoryGameView.GamePhase
    let numbers: [Int]
    @Binding var userInput: [Int]
    let feedbackMessage: String
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            switch gamePhase {
            case .memorize:
                NumberDisplayView(numbers: numbers)
                    .transition(.scale.combined(with: .opacity))
            case .recall:
                NumberInputView(userInput: $userInput, onSubmit: onSubmit)
                    .transition(.slide)
            case .feedback:
                NumberMemoryFeedbackView(
                    message: feedbackMessage,
                    isSuccess: userInput == numbers
                )
                .transition(.scale)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(Color(hex: "#bcebf2").opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut, value: gamePhase)
    }
}

struct NumberDisplayView: View {
    let numbers: [Int]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Memorize")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(Color(hex: "#013640"))
            
            Text(numbers.map(String.init).joined())
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#013640"))
                .padding(32)
                .background(Color(hex: "#bcebf2"))
                .cornerRadius(16)
        }
    }
}

struct NumberInputView: View {
    @Binding var userInput: [Int]
    let onSubmit: () -> Void
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Recall the numbers")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(Color(hex: "#013640"))
            
            TextField("Enter numbers", text: Binding(
                get: { userInput.map(String.init).joined() },
                set: { newValue in
                    userInput = newValue.compactMap { Int(String($0)) }
                }
            ))
            .focused($isInputFocused)
            .foregroundColor(Color(hex: "#02fcee"))
            .font(.system(size: 48, weight: .medium))
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .submitLabel(.done)
            .padding(24)
            .background(Color(hex: "#39484b"))
            .cornerRadius(16)
            
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

struct NumberMemoryFeedbackView: View {
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
