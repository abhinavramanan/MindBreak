import SwiftUI

struct NumberMemoryGameView: View {
    @State private var numbers: [Int] = []
    @State private var userInput: [Int] = []
    @State private var gamePhase = GamePhase.memorize
    @State private var level = 1
    @State private var score = 0
    @State private var feedbackMessage = ""
    
    enum GamePhase {
        case memorize
        case recall
        case feedback
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#02a59c").ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Number Memory")
                            .font(.system(size: 28, weight: .bold))
                        Text("Level \(level)")
                            .font(.system(size: 18))
                    }
                    .foregroundColor(Color(hex: "#013640"))
                    
                    Spacer()
                    
                    Text("Score: \(score)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#013640"))
                }
                .padding()
                .background(Color(hex: "#bcebf2"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Main area that shows the numbers or the input field
                switch gamePhase {
                case .memorize:
                    NumberDisplayView(numbers: numbers)
                case .recall:
                    NumberInputView(
                        userInput: $userInput,
                        onSubmit: checkAnswer
                    )
                case .feedback:
                    FeedbackView(
                        message: feedbackMessage,
                        isSuccess: userInput == numbers
                    )
                }
                
                Spacer()
            }
            .padding()
        }
        // Start the game on appearance
        .onAppear(perform: startNewRound)
    }
    
    /// Initiates a new round for the game.
    private func startNewRound() {
        // Generate new numbers based on current level
        numbers = generateNumbers(count: level + 2)
        userInput = []
        gamePhase = .memorize
        
        // Display numbers for 3 seconds, then switch to the recall phase
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            gamePhase = .recall
        }
    }
    
    /// Generates a random sequence of digits.
    private func generateNumbers(count: Int) -> [Int] {
        // Each digit is randomly picked from 0...9
        (0..<count).map { _ in Int.random(in: 0...9) }
    }
    
    /// Checks the user's input against the generated numbers.
    private func checkAnswer() {
        gamePhase = .feedback
        if userInput == numbers {
            feedbackMessage = "Correct! Great job!"
            score += level * 100
            level += 1
        } else {
            feedbackMessage = "Incorrect. Try again!"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            startNewRound()
        }
    }
}

/// A view to display the numbers for the "memorize" phase.
struct NumberDisplayView: View {
    let numbers: [Int]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Memorize")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(hex: "#013640"))
            
            // Join array of numbers into a single string
            Text(numbers.map(String.init).joined())
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#013640"))
                .padding()
                .background(Color(hex: "#bcebf2"))
                .cornerRadius(16)
        }
    }
}

/// A view to collect the user's recall of the numbers.
struct NumberInputView: View {
    @Binding var userInput: [Int]
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Recall the numbers")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(hex: "#013640"))
            
            // TextField for numeric input
            // Make sure to convert the typed characters to Int values
            TextField("Enter numbers", text: Binding(
                get: { userInput.map(String.init).joined() },
                set: { newValue in
                    userInput = newValue.compactMap { Int(String($0)) }
                }
            ))
            .font(.system(size: 32, weight: .medium))
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .submitLabel(.done) // Show a "Done" button on the keyboard
            .padding()
            .background(Color(hex: "#bcebf2"))
            .cornerRadius(16)
            
            // This is the Submit button
            Button(action: onSubmit) {
                Text("Submit")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#013640"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#02fcee"))
                    .cornerRadius(16)
            }
        }
    }
}

struct FeedbackView: View {
    let message: String
    let isSuccess: Bool
    
    var body: some View {
        VStack {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(
                    isSuccess
                    ? Color(hex: "#02fcee")
                    : Color(hex: "#e17366")
                )
            
            Text(message)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(hex: "#013640"))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(hex: "#bcebf2"))
        .cornerRadius(16)
    }
}
