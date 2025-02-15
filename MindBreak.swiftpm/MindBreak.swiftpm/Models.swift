import SwiftUI

struct CognitiveGame: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let type: GameType
    
    enum GameType {
        case memory, math, pattern, reaction
    }
}

enum GameType {
    case memory
    case math
    case pattern
    case reaction
}
