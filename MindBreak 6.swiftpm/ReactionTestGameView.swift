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
    @State private var feedbackMessage = ""
    @State private var localScore = 0
    @State private var score = 0
    
    @AppStorage("universalScore") private var universalScore: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    private let minWaitTime = 1.5
    private let maxWaitTime = 3.5
    private let feedbackDuration = 1.0
    private let maxAttempts = 10
    
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
                ScoreHeader(
                    bestTime: bestTime,
                    score: score,
                    attempts: attempts,
                    maxAttempts: maxAttempts
                )
                Spacer()
                ReactionGameArea(
                    gameState: gameState,
                    reactionTime: reactionTime,
                    onTap: handleTap
                )
                Spacer()
            }
            .padding()
            
            if showingEarlyTap {
                EarlyTapOverlay()
            }
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
            finishTest()
        }
    }
    
    private func startTest() {
        gameState = .ready
        attempts += 1
        waitTime = Double.random(in: minWaitTime...maxWaitTime)
        
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
        feedbackMessage = "Too early!"
        score = max(0, score - 50)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + feedbackDuration) {
            showingEarlyTap = false
            resetTest()
        }
    }
    
    private func handleReaction() {
        guard let start = startTime else { return }
        let time = Date().timeIntervalSince(start) * 1000 
        reactionTime = time
        
        if let best = bestTime {
            bestTime = min(best, time)
        } else {
            bestTime = time
        }
        
        calculateScore(time: time)
        gameState = .result
    }
    
    private func calculateScore(time: Double) {
        let baseScore = 200
        let penaltyPerMS = 0.5
        let computedScore = max(0, baseScore - Int(time * penaltyPerMS))
        localScore = computedScore
        score += computedScore
        universalScore += computedScore
    }
    
    private func finishTest() {
        if attempts >= maxAttempts {
            dismiss()
        } else {
            resetTest()
        }
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

struct ScoreHeader: View {
    let bestTime: Double?
    let score: Int
    let attempts: Int
    let maxAttempts: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Reaction Test")
                .font(.system(size: 28, weight: .bold))
            
            HStack(spacing: 24) {
                if let best = bestTime {
                    Text("Best: \(String(format: "%.0f", best))ms")
                        .font(.system(size: 20, weight: .bold))
                }
                
                Text("Score: \(score)")
                    .font(.system(size: 20, weight: .bold))
                
                Text("Attempts: \(attempts)/\(maxAttempts)")
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .foregroundColor(Color(hex: "#013640"))
        .padding()
        .background(Color(hex: "#bcebf2"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ReactionGameArea: View {
    let gameState: ReactionTestGameView.GameState
    let reactionTime: Double?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(backgroundColorForState)
                    .frame(width: 280, height: 280)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "#013640"), lineWidth: 4)
                    )
                
                GameContent(gameState: gameState, reactionTime: reactionTime)
            }
        }
    }
    
    private var backgroundColorForState: Color {
        switch gameState {
        case .waiting, .result:
            return Color(hex: "#bcebf2")
        case .ready, .countdown:
            return Color(hex: "#e17366")
        case .react:
            return Color(hex: "#02fcee")
        }
    }
}

struct GameContent: View {
    let gameState: ReactionTestGameView.GameState
    let reactionTime: Double?
    
    var body: some View {
        VStack(spacing: 16) {
            Text(messageForState)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#013640"))
                .multilineTextAlignment(.center)
            
            InstructionsPanel(gameState: gameState)
            
            if case .result = gameState, let time = reactionTime {
                Text("\(String(format: "%.0f", time))ms")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(hex: "#013640"))
            }
        }
        .padding()
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
}

struct InstructionsPanel: View {
    let gameState: ReactionTestGameView.GameState
    
    var body: some View {
        Text(instructionsForState)
            .foregroundColor(Color(hex: "#013640"))
    }
    
    private var instructionsForState: String {
        switch gameState {
        case .waiting:
            return "Tap the circle to begin the test"
        case .ready:
            return "Keep your finger ready"
        case .countdown:
            return "Wait for the green light..."
        case .react:
            return "Tap as quickly as you can!"
        case .result:
            return "Tap to try again"
        }
    }
}

struct EarlyTapOverlay: View {
    var body: some View {
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
