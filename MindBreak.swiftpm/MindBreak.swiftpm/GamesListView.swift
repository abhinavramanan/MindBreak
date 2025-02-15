import SwiftUI

struct GamesListView: View {
    @Binding var isPresented: Bool
    let games: [CognitiveGame]
    @Binding var selectedGame: CognitiveGame?
    @Binding var showingGameView: Bool
    @State private var showHapticFeedback = true
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(spacing: 0) {
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
                VStack(spacing: 8) {
                    ForEach(games) { game in
                        GameCard(game: game)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedGame = game
                                    showingGameView = true
                                    isPresented = false
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .background(Color(hex: "#1f4d53"))
        .clipShape(
            .rect(
                topLeadingRadius: 20,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20
            )
        )
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height > 50 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                }
        )
        .animation(.spring(), value: isPresented)
    }
}
