import SwiftUI

struct PatternMatchGameView: View {
    @State private var grid: [[PatternCell]] = Array(repeating: Array(repeating: PatternCell(), count: 4), count: 4)
    @State private var selectedCells: Set<Int> = []
    @State private var revealedCells: Set<Int> = []
    @State private var score = 0
    @State private var level = 1
    @State private var gamePhase = GamePhase.memorize
    @State private var timeRemaining = 0
    @State private var showingGameOver = false
    @State private var feedbackMessage = ""
    
    @AppStorage("universalScore") private var universalScore: Int = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let gridSize = 4
    private let patternRevealDuration = 2
    private let maxTimePerLevel = 20
    
    enum GamePhase {
        case memorize
        case matching
        case feedback
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#02a59c").ignoresSafeArea()
            VStack(spacing: 24) {
                ScorePanel(
                    level: level,
                    score: score,
                    timeRemaining: timeRemaining
                )
                
                PatternGameArea(
                    gamePhase: gamePhase,
                    grid: grid,
                    gridSize: gridSize,
                    selectedCells: selectedCells,
                    revealedCells: revealedCells,
                    showAllPatterns: gamePhase == .memorize,
                    onCellTap: cellTapped
                )
            }
            .padding(16)
        }
        .alert("Game Over!", isPresented: $showingGameOver) {
            Button("OK") {
                universalScore += score
                dismiss()
            }
        } message: {
            Text("Final Score: \(score)")
        }
        .onAppear(perform: startGame)
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        level = 1
        score = 0
        selectedCells.removeAll()
        revealedCells.removeAll()
        nextLevel()
    }
    
    private func nextLevel() {
        generateNewGrid()
        startTimer()
        gamePhase = .memorize
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(patternRevealDuration)) {
            withAnimation {
                gamePhase = .matching
            }
        }
    }
    
    private func generateNewGrid() {
        // Initialize grid with empty cells
        grid = Array(repeating: Array(repeating: PatternCell(), count: gridSize), count: gridSize)
        selectedCells.removeAll()
        revealedCells.removeAll()
        
        let pairCount = min(level + 1, (gridSize * gridSize) / 2)
        var usedIndices = Set<Int>()
        
        for _ in 0..<pairCount {
            if usedIndices.count >= gridSize * gridSize - 1 { break }
            let pattern = Int.random(in: 0...5)
            
            // Get available positions
            let available = (0..<gridSize*gridSize).filter { !usedIndices.contains($0) }
            guard available.count >= 2 else { break }
            
            // Get two random positions for the pair
            let chosen = available.shuffled().prefix(2)
            for pos in chosen {
                usedIndices.insert(pos)
                let row = pos / gridSize
                let col = pos % gridSize
                if row < grid.count && col < grid[row].count {
                    grid[row][col].pattern = pattern
                }
            }
        }
    }
    
    private func startTimer() {
        timeRemaining = maxTimePerLevel
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                showingGameOver = true
            }
        }
    }
    
    private func cellTapped(row: Int, column: Int) {
        guard gamePhase == .matching else { return }
        guard row < grid.count && column < grid[row].count else { return }
        
        let index = row * gridSize + column
        
        if revealedCells.contains(index) { return }
        
        if selectedCells.contains(index) {
            selectedCells.remove(index)
        } else {
            selectedCells.insert(index)
        }
        
        if selectedCells.count == 2 {
            checkMatch()
        }
    }
    
    private func checkMatch() {
        let selectedArray = Array(selectedCells)
        guard selectedArray.count == 2 else { return }
        
        let firstIndex = selectedArray[0]
        let secondIndex = selectedArray[1]
        
        guard let firstCell = getCellSafely(at: firstIndex),
              let secondCell = getCellSafely(at: secondIndex) else {
            selectedCells.removeAll()
            return
        }
        
        gamePhase = .feedback
        
        if firstCell.pattern == secondCell.pattern && firstCell.pattern != nil {
            score += 100
            revealedCells.insert(firstIndex)
            revealedCells.insert(secondIndex)
            feedbackMessage = "Match found! +100 points"
            
            if isLevelComplete() {
                level += 1
                feedbackMessage = "Level Complete! Moving to level \(level)"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    nextLevel()
                }
            }
        } else {
            feedbackMessage = "No match. Try again!"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            selectedCells.removeAll()
            gamePhase = .matching
        }
    }
    
    private func getCellSafely(at index: Int) -> PatternCell? {
        let row = index / gridSize
        let col = index % gridSize
        guard row < grid.count && col < grid[row].count else { return nil }
        return grid[row][col]
    }
    
    private func isLevelComplete() -> Bool {
        let totalPatternedCells = 2 * min(level + 1, (gridSize * gridSize) / 2)
        return revealedCells.count >= totalPatternedCells
    }
}

// MARK: - Supporting Views

struct ScorePanel: View {
    let level: Int
    let score: Int
    let timeRemaining: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Pattern Match")
                .font(.system(size: 32, weight: .bold))
            
            VStack(spacing: 8) {
                Text("Level \(level)")
                    .font(.system(size: 24))
                
                Text("Score: \(score)")
                    .font(.system(size: 28, weight: .bold))
                
                Label("\(timeRemaining)s", systemImage: "timer")
                    .font(.system(size: 20))
            }
        }
        .foregroundColor(Color(hex: "#013640"))
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(hex: "#bcebf2"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PatternGameArea: View {
    let gamePhase: PatternMatchGameView.GamePhase
    let grid: [[PatternCell]]
    let gridSize: Int
    let selectedCells: Set<Int>
    let revealedCells: Set<Int>
    let showAllPatterns: Bool
    let onCellTap: (Int, Int) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            GridView(
                grid: grid,
                gridSize: gridSize,
                selectedCells: selectedCells,
                revealedCells: revealedCells,
                showAllPatterns: showAllPatterns,
                onCellTap: onCellTap
            )
        }
        .padding(24)
        .background(Color(hex: "#bcebf2").opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut, value: gamePhase)
    }
}

struct GridView: View {
    let grid: [[PatternCell]]
    let gridSize: Int
    let selectedCells: Set<Int>
    let revealedCells: Set<Int>
    let showAllPatterns: Bool
    let onCellTap: (Int, Int) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<gridSize, id: \.self) { column in
                        let index = row * gridSize + column
                        if row < grid.count && column < grid[row].count {
                            PatternCellView(
                                cell: grid[row][column],
                                showPattern: showAllPatterns || revealedCells.contains(index),
                                isTapped: selectedCells.contains(index)
                            )
                            .onTapGesture {
                                onCellTap(row, column)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PatternCellView: View {
    let cell: PatternCell
    let showPattern: Bool
    let isTapped: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "#013640"), lineWidth: 2)
                )
            
            if showPattern, let pattern = cell.pattern {
                Text("\(pattern)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "#013640"))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showPattern)
        .animation(.easeInOut(duration: 0.2), value: isTapped)
    }
    
    private var backgroundColor: Color {
        if isTapped {
            return Color(hex: "#f5d442")
        } else if showPattern {
            return Color(hex: "#02fcee")
        } else {
            return Color(hex: "#bcebf2")
        }
    }
}

// MARK: - Model
struct PatternCell {
    var pattern: Int? = nil
}
