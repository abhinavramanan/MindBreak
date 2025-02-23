import SwiftUI

struct GameCard: View {
    let game: CognitiveGame
    @State private var showGame = false
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(hex: "#bcebf2"))
                
                Text(game.description)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#bcebf2").opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color(hex: "#bcebf2").opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#02a59c"))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .onTapGesture {
            showGame = true
        }
        .sheet(isPresented: $showGame) {
            GameDetailsViewAfterSheet(game: game)
        }
    }
}
