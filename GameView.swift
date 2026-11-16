import SwiftUI

struct GameView: View {
    let game: CognitiveGame
    @Environment(\.dismiss) var dismiss
    @State private var gameScore = 0
    
    var body: some View {
        ZStack {
            Color(hex: "#02a59c")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#bcebf2"))
                    }
                    .padding()
                    
                    Spacer()
                }
                
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
            }
        }
    }
}
