import SwiftUI

struct ReactionTestGameView: View {
    @State private var gameState = GameState.waiting
    @State private var startTime: Date?
    @State private var reactionTime: Double?
    @State private var bestTime: Double?
    @State private var attempts = 0
    @State private var countdownTimer: Timer?
    @State private var waitTime: Double = 0
    @State private var showingEarlyTap = false
    
    // Example local score to demonstrate awarding points upon completion
    @State private var localScore = 0
    
    // Reference the universal score persisted across the app
    @AppStorage("universalScore") private var universalScore: Int = 0
    
    enum GameState {
        case waiting
        case ready
        case countdown
        case react
        case result
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#02a59c").ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Reaction Test")
                        .font(.system(size: 28, weight: .bold))
                    Spacer()
                    if let best = bestTime {
                        Text("Best: \(String(format: "%.0f", best))ms")
                            .font(.system(size: 24, weight: .bold))
                    }
                }
                .foregroundColor(Color(hex: "#013640"))
                .padding()
                .background(Color(hex: "#bcebf2"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
                
                // Main Game Area
                Button(action: handleTap) {
                    ZStack {
                        Circle()
                            .fill(backgroundColorForState)
                            .frame(width: 280, height: 280)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "#013640"), lineWidth: 4)
                            )
                        
                        VStack(spacing: 16) {
                            Text(messageForState)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "#013640"))
                                .multilineTextAlignment(.center)
                            
                            if case .result = gameState, let time = reactionTime {
                                Text("\(String(format: "%.0f", time))ms")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(Color(hex: "#013640"))
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
                
                // Instructions
                Text(instructionsForState)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#013640"))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(hex: "#bcebf2"))
                    .cornerRadius(16)
            }
            .padding()
            
            // Early tap overlay
            if showingEarlyTap {
                Color.black.opacity(0.3).ignoresSafeArea()
                
                VStack {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#e17366"))
                    
                    Text("Too early!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#bcebf2"))
                }
            }
        }
    }
    
    private var backgroundColorForState: Color {
        switch gameState {
        case .waiting:
            return Color(hex: "#bcebf2")
        case .ready:
            return Color(hex: "#e17366")
        case .countdown:
            return Color(hex: "#e17366")
        case .react:
            return Color(hex: "#02fcee")
        case .result:
            return Color(hex: "#bcebf2")
        }
    }
    
    private var messageForState: String {
        switch gameState {
        case .waiting:
            return "Tap to Start"
        case .ready:
            return "Wait for\nGreen"
        case .countdown:
            return "Wait..."
        case .react:
            return "TAP NOW!"
        case .result:
            return "Your Time"
        }
    }
    
    private var instructionsForState: String {
        switch gameState {
        case .waiting:
            return "Tap the circle to begin the test"
        case .ready:
            return "Keep your finger ready to tap when the circle turns green"
        case .countdown:
            return "Wait for the green light..."
        case .react:
            return "Tap as quickly as you can!"
        case .result:
            return "Tap to try again"
        }
    }
    
    private func handleTap() {
        switch gameState {
        case .waiting:
            startTest()
        case .ready, .countdown:
            handleEarlyTap()
        case .react:
            handleReaction()
        case .result:
            // Once the result is shown, add to universal score (example approach)
            universalScore += localScore
            resetTest()
        }
    }
    
    private func startTest() {
        gameState = .ready
        attempts += 1
        waitTime = Double.random(in: 1.5...3.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            gameState = .countdown
            countdownTimer = Timer.scheduledTimer(withTimeInterval: waitTime, repeats: false) { _ in
                gameState = .react
                startTime = Date()
            }
        }
    }
    
    private func handleEarlyTap() {
        countdownTimer?.invalidate()
        showingEarlyTap = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showingEarlyTap = false
            resetTest()
        }
    }
    
    private func handleReaction() {
        guard let start = startTime else { return }
        let time = Date().timeIntervalSince(start) * 1000 // Convert to milliseconds
        reactionTime = time
        
        if let best = bestTime {
            bestTime = min(best, time)
        } else {
            bestTime = time
        }
        
        // Example: scoring formula (the faster, the higher the score)
        let computedScore = max(0, 100 - Int(time / 10))
        localScore = computedScore
        
        gameState = .result
    }
    
    private func resetTest() {
        gameState = .waiting
        startTime = nil
        reactionTime = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        localScore = 0
    }
}

struct ReactionResultView: View {
    let time: Double
    let isBest: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(isBest ? "New Best Time!" : "Your Time")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#013640"))
            
            Text("\(Int(time))ms")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color(hex: "#013640"))
        }
        .padding()
        .background(Color(hex: "#bcebf2"))
        .cornerRadius(16)
    }
}
