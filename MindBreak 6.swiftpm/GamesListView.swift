import SwiftUI

struct GamesListView: View {
    let games = [
        CognitiveGame(title: "Number Memory", description: "Remember and recall a sequence of numbers", type: .memory),
        CognitiveGame(title: "Quick Math", description: "Solve simple math problems quickly", type: .math),
        CognitiveGame(title: "Pattern Match", description: "Find matching patterns in a grid", type: .pattern),
        CognitiveGame(title: "Reaction Test", description: "Test your reaction speed", type: .reaction)
    ]
    @State private var showHapticFeedback = true
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Cognitive Games")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 8)
            
            // Games List
            ScrollView { 
                VStack(spacing: 20) {
                    ForEach(games) { game in
                        GameCard(game: game)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .background(Color(hex: "#1f4d53"))
    }
}
