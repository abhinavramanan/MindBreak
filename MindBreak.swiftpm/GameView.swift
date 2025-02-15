import SwiftUI

// First page: Game Details View
struct GameDetailsView: View {
    let game: CognitiveGame
    @Environment(\.dismiss) var dismiss
    @State private var showGame = false
    
    var body: some View {
        ZStack {
            Color(hex: "#f8f9fa")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(game.title)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(Color(hex: "#202124"))
                    
                    Text(game.description)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#5f6368"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 32)
                
                // Game preview card
                gamePreviewCard
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                
                // Navigation buttons
                VStack(spacing: 16) {
                    Button(action: { showGame = true }) {
                        Text("Start Game")
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "#1a73e8"))
                            .foregroundColor(.white)
                            .cornerRadius(28)
                            .shadow(color: Color(hex: "#1a73e8").opacity(0.3), radius: 8, y: 4)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#1a73e8"))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showGame) {
            GameView(game: game)
        }
    }
    
    var gamePreviewCard: some View {
        Group {
            switch game.type {
            case .memory:
                previewCard(icon: "brain", title: "Memory Game")
            case .math:
                previewCard(icon: "number", title: "Math Game")
            case .pattern:
                previewCard(icon: "square.grid.3x3", title: "Pattern Game")
            case .reaction:
                previewCard(icon: "bolt", title: "Reaction Game")
            }
        }
    }
    
    func previewCard(icon: String, title: String) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "#1a73e8"))
                .padding(.bottom)
            
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(hex: "#202124"))
        }
    }
}

// Second page: Actual Game View
struct GameView: View {
    let game: CognitiveGame
    @Environment(\.dismiss) var dismiss
    @State private var gameScore = 0
    
    var body: some View {
        ZStack {
            Color(hex: "#f8f9fa")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Game content
                Group {
                    switch game.type {
                    case .memory:
                        NumberMemoryGameView()
                    case .math:
                        QuickMathGameView()
                    case .pattern:
                        PatternMatchGameView()
                    case .reaction:
                        ReactionTestGameView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            }
        }
        .navigationBarItems(leading: Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(Color(hex: "#5f6368"))
        })
    }
}
