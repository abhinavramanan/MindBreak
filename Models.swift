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
struct ScoreRecord: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let score: Int
    
    init(timestamp: Date, score: Int) {
        self.id = UUID()
        self.timestamp = timestamp
        self.score = score
    }
}

struct DailyProgressRecord: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let score: Int
    let workTime: Double
    
    init(timestamp: Date, score: Int, workTime: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.score = score
        self.workTime = workTime
    }
}
