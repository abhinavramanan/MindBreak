import SwiftUI

struct GameDetailsView: View {
    let game: CognitiveGame
    @Environment(\.dismiss) var dismiss
    @State private var showGame = false
    @State private var showGameList = false
    
    var body: some View {
        ZStack {
            Color(hex: "#02a59c")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    HStack {
                        Group {
                            switch game.type {
                            case .memory:
                                Image(systemName: "brain")
                                    .font(.system(size: 28, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#013640"))
                                    .frame(width: 40, height: 40)
                                    .padding(20)
                                    .background(Color(hex: "#02fcee"))
                                    .clipShape(Circle())
                            case .math:
                                Image(systemName: "number")
                                    .font(.system(size: 28, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#013640"))
                                    .frame(width: 40, height: 40)
                                    .padding(20)
                                    .background(Color(hex: "#02fcee"))
                                    .clipShape(Circle())
                            case .pattern:
                                Image(systemName: "square.grid.3x3")
                                    .font(.system(size: 28, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#013640"))
                                    .frame(width: 40, height: 40)
                                    .padding(20)
                                    .background(Color(hex: "#02fcee"))
                                    .clipShape(Circle())
                            case .reaction:
                                Image(systemName: "bolt")
                                    .font(.system(size: 28, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#013640"))
                                    .frame(width: 40, height: 40)
                                    .padding(20)
                                    .background(Color(hex: "#02fcee"))
                                    .clipShape(Circle())
                            }
                        }
                        Text(game.title)
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(Color(hex: "#013640"))
                        Spacer()
                    }
                    
                    HStack {
                        Text(game.description)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(Color(hex: "#013640"))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                }
                .padding()
                
                Spacer()
                
                VStack {
                    HStack {
                        Button(action: { showGame = true }) {
                            Label("Play", systemImage: "play.fill")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "#02fcee"))
                                .foregroundColor(Color(hex: "#013640"))
                                .cornerRadius(20)
                                .bold()
                                .shadow(color: Color(hex: "#02fcee").opacity(0.3), radius: 8, y: 4)
                        }
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "#e17366"))
                                .foregroundColor(Color(hex: "#013640"))
                                .bold()
                                .cornerRadius(20)
                        }
                    }
                    
                    Button(action: { showGameList = true }) {
                        Text("Play another game ?")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "#02fcee"))
                            .foregroundColor(Color(hex: "#013640"))
                            .bold()
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showGame) {
            GameView(game: game)
        }
        .sheet(isPresented: $showGameList) {
            GamesListView()
                .background(Color(hex: "#02a59c"))
        }
    }
}
