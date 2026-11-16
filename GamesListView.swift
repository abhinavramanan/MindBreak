import SwiftUI

struct GamesListView: View {
    let games = [
        CognitiveGame(
            title: "Number Memory",
            description: """
        Challenge your short-term memory by remembering sequences of numbers that appear on screen.
        
        This game helps improve your numerical memory retention and recall abilities.
        
        How to Play:
        1. A sequence of numbers will flash on screen for a few seconds
        2. Once the numbers disappear, enter the sequence exactly as shown
        3. Each successful round adds one more digit to remember
        4. Continue until you make a mistake
        """,
            type: .memory    
        ),
        
        CognitiveGame(
            title: "Quick Math",
            description: """
        Put your mental math skills to the test by solving arithmetic problems against the clock. 
        
        This game enhances your calculation speed and numerical agility.
        
        How to Play:
        1. Simple math problems will appear on screen (addition, subtraction, multiplication)
        2. Enter your answer as quickly as possible
        3. Try to solve as many as possible within the time limit
        """,
            type: .math
        ),
        
        CognitiveGame(
            title: "Pattern Match",
            description: """
        Exercise your visual recognition skills and memory by finding matching patterns in a grid of numbers.
        
        This game improves pattern recognition and visual processing speed.
        
        How to Play:
        1. A grid of various patterns of numbers will appear and hide
        2. Find and select pairs of matching numbers
        3. Clear the entire grid by matching all pairs
        4. Complete each level within the time limit
        """,
            type: .pattern
        ),
        
        CognitiveGame(
            title: "Reaction Test",
            description: """
        Measure and improve your reaction time by responding to visual cues as fast as possible. 
        
        This game helps enhance your reflexes and hand-eye coordination.
        
        How to Play:
        1. Wait for the screen to change color
        2. Click/tap as quickly as possible when you see the change
        3. Your reaction time will be measured in milliseconds
        4. Try to beat your best time across multiple attempts
        """,
            type: .reaction
        )
    ]
    
    @State private var showHapticFeedback = true
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                
                Text("Cognitive Games")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#bcebf2"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 8)
            
            
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

